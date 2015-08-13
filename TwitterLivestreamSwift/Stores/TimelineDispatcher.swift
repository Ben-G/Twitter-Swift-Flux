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

// TODO: make dispatcher thread safe using serial queue
let storeQueue = dispatch_queue_create("de.benjamin-encz.twitterswift", nil)

typealias TimelineState = (serverState: [Tweet], localState: [Tweet])
typealias TimelineMergedState = (serverState: [Tweet], localState: [Tweet], mergedState: [Tweet])

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
                let mergedState = mergeListIntoListLeftPriority(timelineState.localState, timelineState.serverState)
              subscriber.newState((serverState: timelineState.serverState, localState: timelineState.localState, mergedState: mergedState))
            }
        }
    }
  
    func subscribe(subscriber: TimelineSubscriber) {
      timelineSubscribers.append(subscriber)
      let mergedState = mergeListIntoListLeftPriority(timelineState.localState, timelineState.serverState)
      subscriber.newState((serverState: timelineState.serverState, localState: timelineState.localState, mergedState: mergedState))
    }
  
}

typealias ActionProviderProvider = () -> ActionProvider
typealias ActionProvider = (state: TimelineState, dispatcher: TimelineDispatcher) -> Action?

protocol TimelineSubscriber {
    func newState(state: TimelineMergedState)
}