//
//  TimelineActionCreator.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 8/12/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import PromiseKit

struct TimelineActionCreator {
    
    static func favoriteTweet(tweet: Tweet) -> ActionProvider {
      return { _ in
        return .FavoriteTweet(tweet)
      }
    }
    
    static func unfavoriteTweet(tweet: Tweet) -> ActionProvider {
      return { _ in
        return .UnfavoriteTweet(tweet)
      }
    }
  
  static func setServerState(state: [Tweet]) -> ActionProvider {
      return { _ in
        return .SetServerState(state)
      }
  }
  
  static func setLocalState(state: [Tweet]) -> ActionProvider {
      return { _ in
        return .SetLocalState(state)
      }
  }
  
  static func fetchServerTweets(count: Int) -> ActionProvider {
    return { state, dispatcher in
      
      fetchTweets(amount: count).then { serverTweets -> Void in
        dispatcher.dispatch { TimelineActionCreator.setServerState(serverTweets) }
      }
      
      return nil
    }
  }
  
  static func syncFavorites() -> ActionProvider {
    return { (var state: TimelineState, dispatcher) -> Action? in
      
      var syncPromises = [Promise<(Tweet?, NSError?)>]()
      var mergedList: [Tweet] = []

      
      login().then {swifter -> () in
        syncPromises = state.localState.map { tweet in
          if (tweet.isFavorited) {
            return syncCreateFavorite(tweet, swifter)
          } else {
            return syncDestroyFavorite(tweet, swifter)
          }
        }
        
        when(syncPromises).then { results -> () in
          
          for result in results {
            
            switch result {
            case (let resultTweet, nil):
              if let resultTweet = resultTweet {
                let index = find(state.localState, resultTweet)
                if let index = index {
                  state.localState.removeAtIndex(index)
                  let index = find(state.serverState, resultTweet)
                  if let index = index {
                    state.serverState[index] = resultTweet
                  }
                }
              }
            case (nil, let error):
              println("One operation failed")
            default:
              println("Something unexpected happened")
            }
          }
          
          dispatcher.dispatch { TimelineActionCreator.setLocalState(state.localState) }
          dispatcher.dispatch { TimelineActionCreator.setServerState(state.serverState) }
      
          }.catch {error in
            // error handling
        }
      }
      
      return nil
    }
  }
  
}