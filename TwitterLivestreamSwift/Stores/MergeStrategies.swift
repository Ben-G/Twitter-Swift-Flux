//
//  MergeStrategies.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 6/4/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

func mergeListIntoListLeftPriority <T : Equatable> (leftList:[T], rightList:[T]) -> [T] {
  var mergedList = [T]()
  mergedList = rightList
  
  mergedList = mergedList.map({ entry -> T in
    let index = find(leftList, entry)
    if let index = index {
      return leftList[index]
    } else {
      return entry
    }
  })
  
  return mergedList
}