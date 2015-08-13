//
//  TimelineActionCreator.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 8/12/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

struct TimelineActionCreator {
    
    static func favoriteTweet(tweet: Tweet) -> ActionProvider {
      return { _ in
        return .FavoriteTweet(tweet)
      }
    }
    
    static func unfavoriteTweet(tweet: Tweet) -> ActionProvider {
      return { _ in
        return .UnfavoriteTweet(tweet)
      }
    }
  
  static func mergeServerState(state: [Tweet]) -> ActionProvider {
      return { _ in
        return .MergeServerState(state)
      }
  }
  
  static func fetchServerTweets(count: Int) -> ActionProvider {
    return { state, dispatcher in
      
      fetchTweets(amount: count).then { serverTweets -> Void in
        dispatcher.dispatch { TimelineActionCreator.mergeServerState(serverTweets) }
      }
      
      return nil
    }
  }
  
}