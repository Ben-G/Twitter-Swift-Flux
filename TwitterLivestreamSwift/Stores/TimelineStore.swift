//
//  TimelineStore.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 8/12/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

struct TimelineStore {
    
    static func handleAction(state: TimelineState = ([],[]), action: Action) -> TimelineState {
        switch action {
        case .FavoriteTweet(let tweet):
            return favoriteTweet(state, tweet: tweet)
        case .UnfavoriteTweet(let tweet):
            return unfavoriteTweet(state, tweet: tweet)
        case .Mount:
            return state
        case .SetServerState(let serverTweets):
          return setServerState(state, serverState: serverTweets)
        case .SetLocalState(let localState):
          return setLocalState(state, localState: localState)
        }
    }
    
    static func favoriteTweet(var state: TimelineState, tweet: Tweet) -> TimelineState {
        let newTweet = Tweet(
            content: tweet.content,
            identifier: tweet.identifier,
            user: tweet.user,
            type: tweet.type,
            favoriteCount: tweet.favoriteCount,
            isFavorited: true
        )
      
        let tweetIndex = find(state.localState, tweet)
      
        if let tweetIndex = tweetIndex {
          // if we have stored local state for this tweet previously, override here
          state.localState[tweetIndex] = newTweet
        } else {
          // else append new state
          state.localState.append(newTweet)
        }
        
        return state
    }
    
    static func unfavoriteTweet(var state: TimelineState, tweet: Tweet) -> TimelineState {
        let newTweet = Tweet(
            content: tweet.content,
            identifier: tweet.identifier,
            user: tweet.user,
            type: tweet.type,
            favoriteCount: tweet.favoriteCount,
            isFavorited: false
        )
        
        let tweetIndex = find(state.localState, tweet)
        
        if let tweetIndex = tweetIndex {
          state.localState[tweetIndex] = newTweet
        } else {
          state.localState.append(newTweet)
      }
      
        return state
    }
  
    static func setServerState(state: TimelineState, serverState: [Tweet]) -> TimelineState {
      var newState = state
        newState.serverState = serverState
      
        return newState
    }
  
    static func setLocalState(var state: TimelineState, localState: [Tweet]) -> TimelineState {
      state.localState = localState
      
      return state
    }
  
}