//
//  TwitterClient.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/25/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import PromiseKit
import Foundation
import Accounts
import SwifteriOS

func fetchTweets(amount:Int = 50) -> Promise<[Tweet]> {
  return login().then(body: {swifter in
    return loadTweets(swifter, amount)
  })
}

private func login() -> Promise<Swifter> {
  let accountType = ACAccountStore().accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
  let accountStore = ACAccountStore()
  
  return Promise { (fulfiller, _) in
    accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (t:Bool, e:NSError!) -> Void in
      // TODO: check if account actually exists
      let accounts = accountStore.accountsWithAccountType(accountType) as [ACAccount]
      let swifter = Swifter(account: accounts[0])
      fulfiller(swifter)
    }
  }
}

private func loadTweets(swifter:Swifter, amount:Int) -> Promise<[Tweet]> {
  return Promise { (fulfiller, _) in

    swifter.getStatusesHomeTimelineWithCount(amount, sinceID: nil, maxID: nil, trimUser: nil, contributorDetails: nil, includeEntities: nil, success: { (statuses) -> Void in
        fulfiller(parseTweets(statuses!))
      }, failure: { (error) -> Void in
    })
  }
}

private func parseTweets(tweets: [JSONValue]) -> [Tweet] {
  return tweets.map({ tweet in
    let user = User (
      profileImageURL:tweet["user"]["profile_image_url"].string!,
      identifier: tweet["user"]["id_str"].string!,
      name: tweet["user"]["name"].string!
    )
    
    var tweetType = Tweet.TweetType.RegularTweet
    if let retweet = tweet["retweeted"].bool {
      tweetType = Tweet.TweetType.Retweet
    }
    
    return Tweet(
      content: tweet["text"].string!,
      retweetCount: tweet["retweet_count"].integer!,
      identifier: tweet["id_str"].string!,
      user: user,
      type: tweetType
    )
  })
}