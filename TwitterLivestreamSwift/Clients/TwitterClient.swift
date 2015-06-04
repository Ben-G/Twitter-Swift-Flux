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

var cachedSwifter: Swifter?

struct StateMerge<T> {
  let originalList: [T]
  let localState: [T]
}

enum SyncResult {
  case Success(StateMerge<Tweet>)
  case Error(StateMerge<Tweet>)
}


func fetchTweets(amount:Int = 50) -> Promise<[Tweet]> {
  return  login().then { swifter in
            return loadTweets(swifter, amount)
          }.then { statuses in
            parseTweets(statuses)
          }
}

func syncFavorites(stateMerge: StateMerge<Tweet>) -> Promise<SyncResult> {
  var originalList = stateMerge.originalList
  var localState = stateMerge.localState
  
  return Promise { fullfil, _ in
    var syncPromises = [Promise<Void>]()
    
      login().then {swifter -> () in
        syncPromises = stateMerge.localState.map { tweet -> Promise<Void> in
          if (tweet.isFavorited) {
            return syncCreateFavorite(tweet, swifter, &localState, &originalList)
          } else {
            return syncDestroyFavorite(tweet, swifter, &localState, &originalList)
          }
        }
        
        when(syncPromises).then { results in
          fullfil(SyncResult.Success(StateMerge(originalList: originalList,localState: localState)))
        }
      }
  }
}

private func syncCreateFavorite(tweet:Tweet, swifter:Swifter, inout localState:[Tweet], inout originalList:[Tweet]) -> Promise<Void> {
  return Promise { fulfill, reject in
    let tweetId = tweet.identifier
    swifter.postCreateFavoriteWithID(tweetId, includeEntities: false, success: { status in
      let index = find(localState, tweet)
      if let index = index {
        originalList = mergeListIntoListLeftPriority(localState, originalList)
        localState.removeAtIndex(index)
      }
      fulfill()
      }, failure: { error in reject(error) })
  }
}

private func syncDestroyFavorite(tweet:Tweet, swifter:Swifter, inout localState:[Tweet], inout originalList:[Tweet]) -> Promise<Void> {
  return Promise { fulfill, reject in
    let tweetId = tweet.identifier
    swifter.postDestroyFavoriteWithID(tweetId, includeEntities: false, success: { status in
      let index = find(localState, tweet)
      if let index = index {
        originalList = mergeListIntoListLeftPriority(localState, originalList)
        localState.removeAtIndex(index)
      }
      fulfill()
      }, failure: { error in reject(error) })
  }
}

private func login() -> Promise<Swifter> {
  let accountType = ACAccountStore().accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
  let accountStore = ACAccountStore()
  
  return Promise { (fulfiller, _) in
    accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (t:Bool, e:NSError!) -> Void in
      
      if let cachedSwifter = cachedSwifter {
        fulfiller(cachedSwifter)
      } else {
        let twitterKeysDictionaryURL = NSBundle.mainBundle().URLForResource("TwitterKeys", withExtension: "plist")
        
        if twitterKeysDictionaryURL == nil {
          println("You need to add a TwitterKey.plist with your consumer key and secret!")
        }
        
        let keys = NSDictionary(contentsOfURL: twitterKeysDictionaryURL!)!
        
        let swifter = Swifter(consumerKey: keys["consumer_key"] as! String, consumerSecret: keys["consumer_secret"] as! String)
        
        swifter.authorizeWithCallbackURL(NSURL(string: "swifter://success")!, success: { (accessToken, response) -> Void in
          
          cachedSwifter = swifter
          fulfiller(swifter)
          }, failure: { (error) -> Void in
            
        })
      }
    }
  }
}

private func loadTweets(swifter:Swifter, amount:Int) -> Promise<[JSONValue]> {
  return Promise { (fulfiller, reject) in

    swifter.getStatusesHomeTimelineWithCount(amount, sinceID: nil, maxID: nil, trimUser: nil, contributorDetails: nil, includeEntities: nil, success: { (statuses) -> Void in
        fulfiller(statuses!)
      }, failure: { error in reject(error) }
    )
  }
}

private func parseTweets(tweets: [JSONValue]) -> [Tweet] {
  return tweets.map({ tweet in
    let user = User (
      profileImageURL:tweet["user"]["profile_image_url"].string!,
      identifier: tweet["user"]["id_str"].string!,
      name: tweet["user"]["name"].string!
    )
    
    var tweetType = Tweet.TweetType.RegularTweet
    if let retweet = tweet["retweeted_status"].object {
      tweetType = Tweet.TweetType.Retweet
    }
    
    let favoriteCount = tweet["favorite_count"].integer ?? 0
    
    var favorited = false
    if let favoritedTweet = tweet["favorited"].integer {
      if (favoritedTweet == 1) {
        favorited = true
      }
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