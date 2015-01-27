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

func fetchTweets(amount:Int = 50) -> Promise<[Tweet]> {
  return login().then(body: {swifter in
    return loadTweets(swifter, amount)
  })
}

func syncFavorites(stateMerge: StateMerge<Tweet>) -> Promise<SyncResult> {
  var originalList = stateMerge.originalList
  var localState = stateMerge.localState
  
  return Promise { fullfil, _ in
    var syncPromises = [Promise<Void>]()
    
      login().then(body: {swifter -> () in
        syncPromises = stateMerge.localState.map { tweet -> Promise<Void> in
          if (tweet.isFavorited) {
            return Promise { fulfill, _ in
              let tweetId = tweet.identifier.toInt()!
              swifter.postCreateFavoriteWithID(tweetId, includeEntities: false, success: { (status) -> Void in
                let index = find(localState, tweet)
                if let index = index {
                  originalList = mergeListIntoListLeftPriority(localState, originalList)
                  localState.removeAtIndex(index)
                }
                fulfill()
                }, failure: { (error) -> Void in })
            }
          } else {
            return Promise { fulfill, _ in
              let tweetId = tweet.identifier.toInt()!
              swifter.postDestroyFavoriteWithID(tweetId, includeEntities: false, success: { (status) -> Void in
                let index = find(localState, tweet)
                if let index = index {
                  originalList = mergeListIntoListLeftPriority(localState, originalList)
                  localState.removeAtIndex(index)
                }
                fulfill()
                }, failure: { (error) -> Void in })
            }
          }
        }
        
        when(syncPromises).then(body: { results in
          fullfil(SyncResult.Success(StateMerge(originalList: originalList,localState: localState)))
        })
      })
  }
}

struct StateMerge<T> {
  let originalList: [T]
  let localState: [T]
}

enum SyncResult {
  case Success(StateMerge<Tweet>)
  case Error(StateMerge<Tweet>)
}

private func login() -> Promise<Swifter> {
  let accountType = ACAccountStore().accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
  let accountStore = ACAccountStore()
  
  return Promise { (fulfiller, _) in
    accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (t:Bool, e:NSError!) -> Void in
      // TODO: check if account actually exists
      let accounts = accountStore.accountsWithAccountType(accountType) as [ACAccount]
      let swifter = Swifter(account: accounts[0])
      fulfiller(swifter)
    }
  }
}

private func loadTweets(swifter:Swifter, amount:Int) -> Promise<[Tweet]> {
  return Promise { (fulfiller, _) in

    swifter.getStatusesHomeTimelineWithCount(amount, sinceID: nil, maxID: nil, trimUser: nil, contributorDetails: nil, includeEntities: nil, success: { (statuses) -> Void in
        fulfiller(parseTweets(statuses!))
      }, failure: { (error) -> Void in
    })
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