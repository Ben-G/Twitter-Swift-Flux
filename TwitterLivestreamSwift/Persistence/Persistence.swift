//
//  Persistence.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/26/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

var favoritedTweets:[String] = []

func mergeTweetsIntoTweetsLeftPriority(tweetsLeft:[Tweet], tweetsRight:[Tweet]) -> [Tweet] {
  var tweets = [Tweet]()
  tweets = tweetsRight
  
  tweets = tweets.map({ tweet -> Tweet in
    let index = find(tweetsLeft, tweet)
    if let index = index {
      return tweetsLeft[index]
    } else {
      return tweet
    }
  })
  
  return tweets
}