//
//  TimelineStore.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 8/12/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

struct TimelineStore {
    
    static func handleAction(state: [Tweet] = [], action: Action) -> TimelineState {
        switch action {
        case .FavoriteTweet(let tweet):
            return favoriteTweet(state, tweet: tweet)
        case .UnfavoriteTweet(let tweet):
            return unfavoriteTweet(state, tweet: tweet)
        case .Mount:
            return state
        case .MergeServerState(let serverTweets):
          return mergeServerTweets(state, serverState: serverTweets)
        }
    }
    
    static func favoriteTweet(var state: [Tweet], tweet: Tweet) -> TimelineState {
        let newTweet = Tweet(
            content: tweet.content,
            identifier: tweet.identifier,
            user: tweet.user,
            type: tweet.type,
            favoriteCount: tweet.favoriteCount,
            isFavorited: true
        )
      
        let tweetIndex = find(state, tweet)
      
        if let tweetIndex = tweetIndex {
          state[tweetIndex] = newTweet
        }
        
        return state
    }
    
    static func unfavoriteTweet(var state: [Tweet], tweet: Tweet) -> TimelineState {
        let newTweet = Tweet(
            content: tweet.content,
            identifier: tweet.identifier,
            user: tweet.user,
            type: tweet.type,
            favoriteCount: tweet.favoriteCount,
            isFavorited: false
        )
        
        let tweetIndex = find(state, tweet)
        
        if let tweetIndex = tweetIndex {
          state[tweetIndex] = newTweet
        }
      
        return state
    }
  
    static func mergeServerTweets(var state: TimelineState, serverState: TimelineState) -> TimelineState {
        return mergeListIntoListLeftPriority(state, serverState)
    }
    
}