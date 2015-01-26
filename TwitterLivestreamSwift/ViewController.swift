//
//  ViewController.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/24/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import UIKit
import SwifteriOS

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView?
  var tweets: [Tweet]?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    fetchTweets().then {tweets -> () in
      self.tweets = tweets
      self.tableView?.reloadData()
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


