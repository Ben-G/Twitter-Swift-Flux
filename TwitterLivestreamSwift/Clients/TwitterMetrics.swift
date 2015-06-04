//
//  TwitterMetrics.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 6/3/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

struct TwitterMetrics {
  
  static func countWordsInTweets(tweets:[Tweet]) -> [(String, Int)] {
    var wordCounts = [String : Int]()
    
    for tweet in tweets {
      let words = split(tweet.content) { $0 == " "}
      for word in words {
        // increase count by 1, or set initially to 1 if first ocurrence of word
        wordCounts[word] = (wordCounts[word] ?? 0) + 1
      }
    }
    
    let sortedKeys = sorted(wordCounts) { $0.1 > $1.1 }
    
    return sortedKeys
  }
  
}