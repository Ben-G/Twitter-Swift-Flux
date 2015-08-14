//
//  TwitterClient.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/25/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import PromiseKit
import Foundation
import Accounts
import SwifteriOS
import UIKit
import SSKeychain

var cachedSwifter: Swifter?

func fetchTweets(amount:Int = 50) -> Promise<[Tweet]> {
  return  login().then { swifter in
    return loadTweets(swifter, amount)
    }.then { statuses -> [Tweet] in
      if let statuses = statuses {
        return parseTweets(statuses)
      } else {
        return [Tweet]()
      }
  }
}

func syncCreateFavorite(tweet:Tweet, swifter:Swifter) -> Promise<(Tweet?, NSError?)> {
  return Promise { fulfill, reject in
    let tweetId = tweet.identifier
    swifter.postCreateFavoriteWithID(tweetId, includeEntities: false, success: { status in
      fulfill(tweet, nil)
      }, failure: { error in reject(error) })
  }
}

func syncDestroyFavorite(tweet:Tweet, swifter:Swifter) -> Promise<(Tweet?, NSError?)> {
  return Promise { fulfill, reject in
    let tweetId = tweet.identifier
    swifter.postDestroyFavoriteWithID(tweetId, includeEntities: false, success: { status in
      fulfill(tweet, nil)
      }, failure: { error in
        fulfill(nil,error)
    })
  }
}

func login() -> Promise<Swifter> {
  let accountType = ACAccountStore().accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
  let accountStore = ACAccountStore()
  
  return Promise { (fulfiller, _) in
    accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (t:Bool, e:NSError!) -> Void in
      
      let twitterKeysDictionaryURL = NSBundle.mainBundle().URLForResource("TwitterKeys", withExtension: "plist")
      
      if twitterKeysDictionaryURL == nil {
        println("You need to add a TwitterKey.plist with your consumer key and secret!")
      }
      
      let keys = NSDictionary(contentsOfURL: twitterKeysDictionaryURL!)!
      
      let cachedKey = SSKeychain.passwordForService("twitterOAuthAccessTokenKey", account: "")
      let cachedSecret = SSKeychain.passwordForService("twitterOAuthAccessTokenSecret", account: "")
      
      if let cachedSwifter = cachedSwifter {
        fulfiller(cachedSwifter)
      } else if let cachedKey = cachedKey, cachedSecret = cachedSecret {
        let accessToken = SwifterCredential.OAuthAccessToken(key: cachedKey, secret: cachedSecret)
        let credential = SwifterCredential(accessToken: accessToken)
        
        let swifter = Swifter(consumerKey: keys["consumer_key"] as! String, consumerSecret: keys["consumer_secret"] as! String, oauthToken: cachedKey, oauthTokenSecret: cachedSecret)
        cachedSwifter = swifter
        fulfiller(swifter)
      } else {
        let swifter = Swifter(consumerKey: keys["consumer_key"] as! String, consumerSecret: keys["consumer_secret"] as! String)
        
        swifter.authorizeWithCallbackURL(NSURL(string: "swifter://success")!, success: { (accessToken, response) -> Void in
          // TODO: cache access token here
          cachedSwifter = swifter
          
          SSKeychain.setPassword(accessToken!.key, forService: "twitterOAuthAccessTokenKey", account: "")
          SSKeychain.setPassword(accessToken!.secret, forService: "twitterOAuthAccessTokenSecret", account: "")
          
          
          fulfiller(swifter)
          }, failure: { (error) -> Void in
            
        })
      }
    }
  }
}

private func loadTweets(swifter:Swifter, amount:Int) -> Promise<[JSONValue]?> {
  return Promise { (fulfiller, reject) in
    
    swifter.getStatusesHomeTimelineWithCount(amount, sinceID: nil, maxID: nil, trimUser: nil, contributorDetails: nil, includeEntities: nil, success: { (statuses) -> Void in
      fulfiller(statuses)
      }, failure: { error in reject(error) }
    )
  }
}

private func parseTweets(tweets: [JSONValue]) -> [Tweet] {
  return tweets.map({ tweet in
    let user = User (
      profileImageURL: profilePictureURLForCurrentDeviceType(tweet),
      identifier: tweet["user"]["id_str"].string!,
      name: tweet["user"]["name"].string!
    )
    
    var tweetType = Tweet.TweetType.RegularTweet
    if let retweet = tweet["retweeted_status"].object {
      tweetType = Tweet.TweetType.Retweet
    }
    
    let favoriteCount = tweet["favorite_count"].integer ?? 0
    
    var favorited = false
    if let favoritedTweet = tweet["favorited"].bool {
      favorited = favoritedTweet
    }
    
    return Tweet(
      content: tweet["text"].string!,
      identifier: tweet["id_str"].string!,
      user: user,
      type: tweetType,
      favoriteCount:favoriteCount,
      isFavorited: favorited
    )
  })
}


private func profilePictureURLForCurrentDeviceType(tweet: JSONValue) -> String {
  var regularPictureURL = tweet["user"]["profile_image_url_https"].string!
  
  if (UIScreen.mainScreen().scale >= 2.0) {
    var largePictureURL = (regularPictureURL as NSString).mutableCopy() as! NSMutableString
    largePictureURL.replaceOccurrencesOfString("_normal.png", withString: "_bigger.png", options: NSStringCompareOptions.BackwardsSearch, range: NSRange(location: 0, length: largePictureURL.length))
    
    return largePictureURL as String
  } else {
    return regularPictureURL
  }
}
