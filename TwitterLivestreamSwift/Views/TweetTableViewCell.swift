//
//  TweetTableViewCell.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/26/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import UIKit

class TweetTableViewCell: UITableViewCell {
  
  @IBOutlet weak var profilePictureImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  
  var tweet:Tweet? {
    didSet {
      if let tweet = tweet {
        userNameLabel.text = tweet.user.name
        contentLabel.text = tweet.content
      }
    }
  }
}