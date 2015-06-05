//
//  TweetStore.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 6/4/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import PromiseKit

class TweetStore {
 
  var tweets: [Tweet]? {
    get {
      return mergeListIntoListLeftPriority(localState, serverTweets!)
    }
  }
  
  var serverTweets: [Tweet]?
  
  private var localState: [Tweet] = []

  func loadTweets() -> Promise<[Tweet]> {
    return Promise { fulfill, reject in
      fetchTweets(amount:800).then {[weak self] tweets -> () in
        if self == nil {
          return
        }
        
        self!.serverTweets = tweets
        fulfill(tweets)
      }.catch { error in
        println(error.localizedDescription)
        reject(error)
      }
    }
  }
  
  func addTweetChangeToLocalState(tweet: Tweet) {
    let index = find(localState, tweet)
    if let index = index {
      localState[index] = tweet
    } else {
      localState.append(tweet)
    }
    
    postFavorites()
  }
  
  func postFavorites() {
    // handle upload
    let stateMerge = StateMerge(originalList:self.serverTweets!, localState: self.localState)
    
    syncFavorites(StateMerge(originalList:serverTweets!, localState: localState))
      .then{ syncResult -> () in
        switch syncResult {
        case SyncResult.Success(let stateMerge):
          // store the remainder of local changes that could not be synced
          // in success case this will always be an empty list
          self.localState = stateMerge.localState
          self.serverTweets = stateMerge.originalList
        case SyncResult.Error(let stateMerge):
          // store the remainder of local changes that could not be synced
          // potentially display an error message
          self.localState = stateMerge.localState
          self.serverTweets = stateMerge.originalList
        }
    }
  }
}