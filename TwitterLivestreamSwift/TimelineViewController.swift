//
//  ViewController.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/24/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import UIKit
import SwifteriOS

class TimelineViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView?
  @IBOutlet weak var wordCountLabel: UILabel!

  
  var filter:TweetFilter = { $0 } {
    didSet {
      tweets = filter(mergeListIntoListLeftPriority(localState, serverTweets!))
    }
  }
  
  var serverTweets: [Tweet]? {
    didSet {
      tweets = filter(mergeListIntoListLeftPriority(localState, serverTweets!))
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
  }
  
  func loadTweets() {
    fetchTweets(amount:800).then {[weak self] tweets -> () in
      if self == nil {
        return
      }
      
      self!.serverTweets = tweets
      
    }.catch { error in
      println(error.localizedDescription)
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
  
  func postFavorites() {
    // handle upload
    let stateMerge = StateMerge(originalList:self.serverTweets!, localState: self.localState)
  
    syncFavorites(StateMerge(originalList:serverTweets!, localState: localState))
      .then{ syncResult -> () in
        switch syncResult {
        case SyncResult.Success(let stateMerge):
          // store the remainder of local changes that could not be synced
          // in success case this will always be an empty list
          self.localState = stateMerge.localState
          self.serverTweets = stateMerge.originalList
        case SyncResult.Error(let stateMerge):
          // store the remainder of local changes that could not be synced
          // potentially display an error message
          self.localState = stateMerge.localState
          self.serverTweets = stateMerge.originalList
        }
    }
  }

}

extension TimelineViewController: UITableViewDataSource {
  
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

extension TimelineViewController : TweetTableViewCellFavoriteDelegateProtocol {
  
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
    
    postFavorites()
  }
}

extension TimelineViewController {
  
  @IBAction func retweetsButtonTapped(sender: AnyObject) {
    filter = Retweets
  }
  
  @IBAction func favoritedButtonTapped(sender: AnyObject) {
    filter = Favorited
  }
  
  @IBAction func allTweetsButtonTapped(sender: AnyObject) {
    filter = { $0 }
  }
  
  @IBAction func wordCountButtonTapped(sender: AnyObject) {
    wordCountLabel.text = "Counting ..."
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let counts = TwitterMetrics.countWordsInTweets(self.tweets!)
      let (word, count) = counts[0]
      dispatch_async(dispatch_get_main_queue()) {
        self.wordCountLabel.text = "Most frequent word: \(word); \(count) times"
      }
    })
  }
  
}


