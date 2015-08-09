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


struct TwitterClient : StoreSync {

  static func syncLocalState(stateMerge: StateMerge<Tweet>) -> Promise<SyncResult<Tweet>> {
    var originalList = stateMerge.originalList
    var localState = stateMerge.localState
    
    return Promise { fullfil, reject in
      var syncPromises = [Promise<(Tweet?, NSError?)>]()
      
      login().then {swifter -> () in
        syncPromises = stateMerge.localState.map { tweet in
          if (tweet.isFavorited) {
            return syncCreateFavorite(tweet, swifter)
          } else {
            return syncDestroyFavorite(tweet, swifter)
          }
        }
        
        when(syncPromises).then { results -> () in
          
          for result in results {
            
            switch result {
            case (let resultTweet, nil):
              if let resultTweet = resultTweet {
                let index = find(localState, resultTweet)
                if let index = index {
                  originalList = mergeListIntoListLeftPriority(localState, originalList)
                  localState.removeAtIndex(index)
                }
              }
            case (nil, let error):
              println("One operation failed")
            default:
              println("Something unexpected happened")
            }
          }
          
          //TODO: update local and original state here
          
          fullfil(SyncResult.Success(StateMerge(originalList: originalList, localState: localState)))
        }.catch {error in
            reject(error)
        }
      }
    }
  }

  
}


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

private func syncCreateFavorite(tweet:Tweet, swifter:Swifter) -> Promise<(Tweet?, NSError?)> {
  return Promise { fulfill, reject in
    let tweetId = tweet.identifier
    swifter.postCreateFavoriteWithID(tweetId, includeEntities: false, success: { status in
      fulfill(tweet, nil)
    }, failure: { error in reject(error) })
  }
}

private func syncDestroyFavorite(tweet:Tweet, swifter:Swifter) -> Promise<(Tweet?, NSError?)> {
  return Promise { fulfill, reject in
    let tweetId = tweet.identifier
    swifter.postDestroyFavoriteWithID(tweetId, includeEntities: false, success: { status in
      fulfill(tweet, nil)
    }, failure: { error in
      fulfill(nil,error)
    })
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