//
//  ViewController.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/24/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import UIKit
import SwifteriOS

typealias TweetFilter = [Tweet] -> [Tweet]

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView?
  
  var filters:[TweetFilter]?
  var timer:NSTimer?
  
  var serverTweets: [Tweet]? {
    didSet {
      tweets = mergeListIntoListLeftPriority(localState, serverTweets!)
    }
  }
  
  var tweets: [Tweet]? {
    didSet {
      if let tweets = tweets {
        self.tableView?.reloadData()
      }
    }
  }
  
  var localState: [Tweet] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadTweets()
    
//    timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("loadTweets"), userInfo: nil, repeats: true)
  }
  
  func loadTweets() {
    fetchTweets(amount:3200).then {[weak self] tweets -> () in
      if self == nil {
        return
      }
      
      var filteredTweets = tweets
      
      if let filters = self!.filters {
        for Filter in filters {
          filteredTweets = Filter(filteredTweets)
        }
      }
      
      self!.serverTweets = filteredTweets
      
      // handle upload
      syncFavorites(StateMerge(originalList:self!.serverTweets!, localState: self!.localState))
        .then { syncResult -> () in
        
        switch syncResult {
        case SyncResult.Success(let stateMerge):
            // store the remainder of local changes that could not be synced
            // in success case this will always be an empty list
            self!.localState = stateMerge.localState
            self!.serverTweets = stateMerge.originalList
        case SyncResult.Error(let stateMerge):
            // store the remainder of local changes that could not be synced
            // potentially display an error message
            self!.localState = stateMerge.localState
            self!.serverTweets = stateMerge.originalList
        }
      }
    }
  }
  
  func addTweetChangeToLocalState(tweet: Tweet) {
    let index = find(localState, tweet)
    if let index = index {
      localState[index] = tweet
    } else {
      localState.append(tweet)
    }
  }

}

extension ViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let tweets = tweets {
      let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as! TweetTableViewCell
      cell.tweet = tweets[indexPath.row]
      cell.favoriteDelegate = self
      return cell
    } else {
      return UITableViewCell()
    }
  }
}

extension ViewController : TweetTableViewCellFavoriteDelegateProtocol {
  
  func didFavorite(tweetTableViewCell:TweetTableViewCell) {
    let currentTweet = tweetTableViewCell.tweet!
    
    let newTweet = Tweet(
      content: currentTweet.content,
      identifier: currentTweet.identifier,
      user: currentTweet.user,
      type: currentTweet.type,
      favoriteCount: currentTweet.favoriteCount,
      isFavorited: !currentTweet.isFavorited
    )
    
    addTweetChangeToLocalState(newTweet)
    tweets = mergeListIntoListLeftPriority([newTweet], tweets!)
  }
}
