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

func fetchTweets() -> Promise<[Tweet]> {
  return login().then(body: {swifter in
    return loadTweets(swifter)
  })
}

func login() -> Promise<Swifter> {
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

func loadTweets(swifter:Swifter) -> Promise<[Tweet]> {
  return Promise { (fulfiller, _) in

    swifter.getStatusesHomeTimelineWithCount(20, sinceID: nil, maxID: nil, trimUser: nil, contributorDetails: nil, includeEntities: nil, success: { (statuses) -> Void in
        fulfiller(parseTweets(statuses!))
      }, failure: { (error) -> Void in
      
    })
  }
}

func parseTweets(tweets: [JSONValue]) -> [Tweet] {
  return tweets.map({ tweet in
    Tweet(content: tweet["text"].string!)
  })
}