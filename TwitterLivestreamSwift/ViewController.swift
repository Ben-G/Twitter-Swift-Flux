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
        // TODO: apply all filters
        self.tableView?.reloadData()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    fetchTweets().then {tweets -> () in
      self.tweets = tweets
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


