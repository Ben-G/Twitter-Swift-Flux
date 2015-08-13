//
//  TimelineDispatcher.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 8/12/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

/**
Maintains State
*/

typealias TimelineState = [Tweet]

class TimelineDispatcher {
    
    private var timelineState: TimelineState = TimelineStore.handleAction(action: .Mount)
    private var timelineSubscribers: [TimelineSubscriber] = []
    
    func dispatch(actionProvider: ActionProviderProvider) {
        // find store
        let action = actionProvider()(state: timelineState, dispatcher: self)
        if let providedAction = action {
            timelineState = TimelineStore.handleAction(state: timelineState, action: providedAction)
            // update subscribers with new state
            for subscriber in timelineSubscribers {
                subscriber.newState(timelineState)
            }
        }
    }
  
  func subscribe(subscriber: TimelineSubscriber) {
    timelineSubscribers.append(subscriber)
    subscriber.newState(timelineState)
  }
  
}

typealias ActionProviderProvider = () -> ActionProvider
typealias ActionProvider = (state: TimelineState, dispatcher: TimelineDispatcher) -> Action?

protocol TimelineSubscriber {
    func newState(state: TimelineState)
}