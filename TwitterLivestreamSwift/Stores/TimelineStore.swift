//
//  TimelineStore.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 8/12/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

struct TimelineStore {
    
    static func handleAction(state: [Tweet] = [], action: Action) -> [Tweet] {
        switch action {
        case .FavoriteTweet(let tweet):
            return favoriteTweet(state, tweet: tweet)
        case .UnfavoriteTweet(let tweet):
            return unfavoriteTweet(state, tweet: tweet)
        case .Mount:
            return state
        }
    }
    
    static func favoriteTweet(var state: [Tweet], tweet: Tweet) -> [Tweet] {
        let newTweet = Tweet(
            content: tweet.content,
            identifier: tweet.identifier,
            user: tweet.user,
            type: tweet.type,
            favoriteCount: tweet.favoriteCount,
            isFavorited: true
        )
        
        state.append(tweet)
        
        return state
    }
    
    static func unfavoriteTweet(var state: [Tweet], tweet: Tweet) -> [Tweet] {
        let newTweet = Tweet(
            content: tweet.content,
            identifier: tweet.identifier,
            user: tweet.user,
            type: tweet.type,
            favoriteCount: tweet.favoriteCount,
            isFavorited: false
        )
        
        state.append(tweet)
        
        return state
    }
    
}