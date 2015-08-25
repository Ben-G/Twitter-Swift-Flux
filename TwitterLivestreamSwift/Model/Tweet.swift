//
//  Tweet.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/25/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

struct Tweet : LastUpdateProcotol {
  let content: String
  let identifier: String
  let user: User
  let type: Tweet.TweetType
  let favoriteCount: Int
  let isFavorited: Bool
  let lastUpdate = NSDate().timeIntervalSinceReferenceDate
  
  enum TweetType {
    case RegularTweet
    case Retweet
  }
}

func ==(lhs: Tweet, rhs: Tweet) -> Bool {
  return lhs.identifier == rhs.identifier
}

protocol LastUpdateProcotol: Equatable {
  var lastUpdate: NSTimeInterval { get }
}