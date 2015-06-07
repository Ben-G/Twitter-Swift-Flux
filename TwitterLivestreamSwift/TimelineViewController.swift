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

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var wordCountLabel: UILabel!
  var refreshControl: UIRefreshControl!

  var store: TweetStore = TweetStore()
  
  var filter:TweetFilter = TweetFilters.all {
    didSet {
      tableView?.reloadData()
    }
  }
  
  var tweets: [Tweet]? {
    didSet {
      if let tweets = tweets {
        tableView?.reloadData()
      }
    }
  }
  
  var displayedTweets: [Tweet] {
    get {
      if let tweets = tweets {
        return filter(tweets)
      } else {
        return []
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    tableView.insertSubview(refreshControl, atIndex:0)
    
    refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
    store.loadTweets().then { tweets in
      self.tweets = tweets
    }
  }
  
  func refresh() {
    store.loadTweets().then { tweets in
      self.tweets = tweets
    }

    refreshControl.endRefreshing()
  }
}

extension TimelineViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayedTweets.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let tweets = tweets {
      let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as! TweetTableViewCell
      cell.tweet = displayedTweets[indexPath.row]
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
    
    store.addTweetChangeToLocalState(newTweet)
    store.syncLocalState()
    tweets = store.tweets
  }
}

extension TimelineViewController {
  
  @IBAction func retweetsButtonTapped(sender: AnyObject) {
    filter = TweetFilters.retweets
  }
  
  @IBAction func favoritedButtonTapped(sender: AnyObject) {
    filter = TweetFilters.favorited
  }
  
  @IBAction func allTweetsButtonTapped(sender: AnyObject) {
    filter = TweetFilters.all
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


