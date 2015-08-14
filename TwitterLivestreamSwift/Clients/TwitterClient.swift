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

struct TwitterClient {
  
  static func fetchTweets(amount:Int = 50) -> Promise<[Tweet]> {
    return  login().then { swifter in
      return self.loadTweets(swifter, amount: amount)
      }.then { statuses -> [Tweet] in
        if let statuses = statuses {
          return self.parseTweets(statuses)
        } else {
          return [Tweet]()
        }
    }
  }
  
  static func syncCreateFavorite(tweet:Tweet, swifter:Swifter) -> Promise<(Tweet?, NSError?)> {
    return Promise { fulfill, reject in
      let tweetId = tweet.identifier
      swifter.postCreateFavoriteWithID(tweetId, includeEntities: false, success: { status in
        fulfill(tweet, nil)
        }, failure: { error in reject(error) })
    }
  }
  
  static func syncDestroyFavorite(tweet:Tweet, swifter:Swifter) -> Promise<(Tweet?, NSError?)> {
    return Promise { fulfill, reject in
      let tweetId = tweet.identifier
      swifter.postDestroyFavoriteWithID(tweetId, includeEntities: false, success: { status in
        fulfill(tweet, nil)
        }, failure: { error in
          fulfill(nil,error)
      })
    }
  }
  
  static var cachedSwifter: Swifter?
  
  static func login() -> Promise<Swifter> {
    let accountType = ACAccountStore().accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    let accountStore = ACAccountStore()
    
    return Promise { (fulfiller, _) in
      accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (t:Bool, e:NSError!) -> Void in
        
        let (consumerKey, consumerSecret) = Authentication.retrieveApplicationAuthPair()
        let nativeAccount = ACAccountStore().accountsWithAccountType(accountType).last as? ACAccount
        
        if let cachedSwifter = self.cachedSwifter {
          fulfiller(cachedSwifter)
        } else if let nativeAccount = nativeAccount {
          let swifter = Swifter(account: nativeAccount)
          fulfiller(swifter)
        } else if let (cachedKey, cachedSecret) = Authentication.retrieveOAuthAccessPair() {
          let accessToken = SwifterCredential.OAuthAccessToken(key: cachedKey, secret: cachedSecret)
          let credential = SwifterCredential(accessToken: accessToken)
          let swifter = Swifter(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: cachedKey, oauthTokenSecret: cachedSecret)
          self.cachedSwifter = swifter
          fulfiller(swifter)
        } else {
          let swifter = Swifter(consumerKey: consumerKey, consumerSecret: consumerSecret)
          
          swifter.authorizeWithCallbackURL(NSURL(string: "swifter://success")!, success: { (accessToken, response) -> Void in
            self.cachedSwifter = swifter
            Authentication.saveOAuthAccessPair(OAuthAccessPair(key: accessToken!.key, secret: accessToken!.secret))
            fulfiller(swifter)
            
            }, failure: { (error) -> Void in
              // TODO: handle error case
          })
        }
      }
    }
  }
  
  static private func loadTweets(swifter:Swifter, amount:Int) -> Promise<[JSONValue]?> {
    return Promise { (fulfiller, reject) in
      
      swifter.getStatusesHomeTimelineWithCount(amount, sinceID: nil, maxID: nil, trimUser: nil, contributorDetails: nil, includeEntities: nil, success: { (statuses) -> Void in
        fulfiller(statuses)
        }, failure: { error in reject(error) }
      )
    }
  }
  
  static private func parseTweets(tweets: [JSONValue]) -> [Tweet] {
    return tweets.map({ tweet in
      let user = User (
        profileImageURL: self.profilePictureURLForCurrentDeviceType(tweet),
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
  
  
  static private func profilePictureURLForCurrentDeviceType(tweet: JSONValue) -> String {
    var regularPictureURL = tweet["user"]["profile_image_url_https"].string!
    
    if (UIScreen.mainScreen().scale >= 2.0) {
      var largePictureURL = (regularPictureURL as NSString).mutableCopy() as! NSMutableString
      largePictureURL.replaceOccurrencesOfString("_normal.png", withString: "_bigger.png", options: NSStringCompareOptions.BackwardsSearch, range: NSRange(location: 0, length: largePictureURL.length))
      
      return largePictureURL as String
    } else {
      return regularPictureURL
    }
  }

  
}