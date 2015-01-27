//
//  Persistence.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/26/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

var favoritedTweets:[String] = []

func toggleFavoriteState(tweet:Tweet) -> Bool {
  var index = find(favoritedTweets, tweet.identifier)
  if let index = index {
    favoritedTweets.removeAtIndex(index)
    return false
  } else {
    favoritedTweets.append(tweet.identifier)
    return true
  }
}

func isTweetFavorited(tweet:Tweet) -> Bool {
  var index = find(favoritedTweets, tweet.identifier)
  if let index = index {
    return true
  } else {
    return false
  }
}