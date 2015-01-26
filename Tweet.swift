//
//  Tweet.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/25/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

struct Tweet {
  let content: String
  let retweetCount: Int
  let identifier: String
  let user: User
  let type: Tweet.TweetType
  
  enum TweetType {
    case RegularTweet
    case Retweet
  }
}