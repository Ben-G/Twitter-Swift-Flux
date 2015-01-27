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
  
  var tweets: [Tweet]? {
    didSet {
      if let tweets = tweets {
        self.tableView?.reloadData()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.filters = [Retweets]
    
    fetchTweets().then {[weak self] tweets -> () in
      if self == nil {
        return
      }
      
      var filteredTweets = tweets
      
      if let filters = self!.filters {
        for Filter in filters {
          filteredTweets = Filter(filteredTweets)
        }
      }
      
      self!.tweets = filteredTweets
    }
  }
}

extension ViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let tweets = tweets {
      let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as TweetTableViewCell
      cell.tweet = tweets[indexPath.row]
      return cell
    } else {
      return UITableViewCell()
    }
  }

}


