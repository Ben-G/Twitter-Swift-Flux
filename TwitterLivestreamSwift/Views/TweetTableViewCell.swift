//
//  TweetTableViewCell.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/26/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

protocol TweetTableViewCellFavoriteDelegateProtocol : class {
  func didFavorite(tweetTableViewCell:TweetTableViewCell)
}

class TweetTableViewCell: UITableViewCell {
  
  @IBOutlet weak var profilePictureImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  
  weak var favoriteDelegate: TweetTableViewCellFavoriteDelegateProtocol?
  weak var currentImageRequest: Request?
  
  var tweet:Tweet? {
    didSet {
      if let tweet = tweet {
        if (tweet.isFavorited) {
          self.contentView.backgroundColor = UIColor.lightGrayColor()
        } else {
          self.contentView.backgroundColor = UIColor.whiteColor()
        }
        
        if tweet.identifier == oldValue?.identifier {
          return
        }
        
        // reset the image before we start loading the new one
        profilePictureImageView.image = nil
        userNameLabel.text = tweet.user.name
        contentLabel.text = tweet.content
        
        // cancel any previous request that might be going on
        currentImageRequest?.cancel()
        
        let (imageDownloadPromise, imageRequest) = fetchImage(tweet.user.profileImageURL)
        currentImageRequest = imageRequest
        
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