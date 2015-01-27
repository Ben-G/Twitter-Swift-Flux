//
//  TweetTableViewCell.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/26/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import UIKit

protocol TweetTableViewCellFavoriteDelegateProtocol : class {
  func didFavorite(tweetTableViewCell:TweetTableViewCell)
}

class TweetTableViewCell: UITableViewCell {
  
  @IBOutlet weak var profilePictureImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  
  weak var favoriteDelegate:TweetTableViewCellFavoriteDelegateProtocol?
  
  var tweet:Tweet? {
    didSet {
      if tweet?.identifier == oldValue?.identifier {
        if (tweet!.isFavorited) {
          self.contentView.backgroundColor = UIColor.lightGrayColor()
        } else {
          self.contentView.backgroundColor = UIColor.whiteColor()
        }
        
        return
      }
      
      if let tweet = tweet {
        // reset the image before we start loading the new one
        profilePictureImageView.image = nil
        userNameLabel.text = tweet.user.name
        contentLabel.text = tweet.content
        
        let imageDownloadPromise = fetchImage(tweet.user.profileImageURL)
        
        imageDownloadPromise.then { [weak self] image -> () in
          if let nonOptionalSelf = self {
            if (nonOptionalSelf.tweet?.identifier == tweet.identifier) {
              nonOptionalSelf.profilePictureImageView.image = image
            }
          }
        }
        
        imageDownloadPromise.catch { [weak self] e->() in
          if let nonOptionalSelf = self {
            nonOptionalSelf.profilePictureImageView.image = nil
          }
        }
        
      }
    }
  }
  
  @IBAction func favoriteButtonPressed(sender: AnyObject) {
    if let favoriteDelegate = favoriteDelegate {
      favoriteDelegate.didFavorite(self)
    }
  }

}