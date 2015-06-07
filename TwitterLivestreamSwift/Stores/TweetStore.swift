//
//  TweetStore.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 6/4/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import PromiseKit

struct StateMerge <T> {
  let originalList: [T]
  let localState: [T]
}

enum SyncResult <T> {
  case Success(StateMerge<T>)
  case Error(StateMerge<T>)
}

protocol StoreSync {
  typealias StoreType
  
  static func syncLocalState(merge: StateMerge<StoreType>) -> Promise<SyncResult<StoreType>>
}

class TweetStore {
 
  var tweets: [Tweet]? {
    get {
      return mergeListIntoListLeftPriority(localState, serverTweets)
    }
  }
  
  private var serverTweets: [Tweet] = []
  private var localState: [Tweet] = []

  func loadTweets() -> Promise<[Tweet]> {
    return Promise { fulfill, reject in
      fetchTweets(amount:800).then {[unowned self] tweets -> () in
        self.serverTweets = tweets
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
  }
  
  func syncLocalState() {
    // handle upload
    let stateMerge = StateMerge(originalList:self.serverTweets, localState: self.localState)
    
    TwitterClient.syncLocalState(StateMerge(originalList:serverTweets, localState: localState))
      .then{ syncResult -> () in
        switch syncResult {
        case SyncResult.Success(let stateMergeResult):
          // store the remainder of local changes that could not be synced
          // in success case this will always be an empty list
          self.localState = stateMergeResult.localState
          self.serverTweets = stateMergeResult.originalList
        case SyncResult.Error(let stateMergeResult):
          // store the remainder of local changes that could not be synced
          // potentially display an error message
          self.localState = stateMergeResult.localState
          self.serverTweets = stateMergeResult.originalList
        }
    }
  }
}