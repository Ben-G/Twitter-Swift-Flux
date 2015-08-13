//
//  TimelineActionCreator.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 8/12/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

struct TimelineActionCreator {
    
    func favoriteTweet(tweet: Tweet) -> Action {
        return .FavoriteTweet(tweet)
    }
    
    func unfavoriteTweet(tweet: Tweet) -> Action {
        return .UnfavoriteTweet(tweet)
    }
    
}