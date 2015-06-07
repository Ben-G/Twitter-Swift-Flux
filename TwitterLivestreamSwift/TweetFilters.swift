//
//  TweetFilters.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/26/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

typealias TweetFilter = [Tweet] -> [Tweet]

struct TweetFilters {
  static let retweets: TweetFilter = {tweets in
    tweets.filter { tweet in
      return tweet.type == Tweet.TweetType.Retweet
    }
  }

  static let favorited: TweetFilter = {tweets in
    tweets.filter { tweet in
      return tweet.favoriteCount > 0
    }
  }

  static let all: TweetFilter = { $0 }
}