//
//  TimelineStoreActions.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 8/12/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

enum Action {
    case Mount
    case FavoriteTweet(Tweet)
    case UnfavoriteTweet(Tweet)
}