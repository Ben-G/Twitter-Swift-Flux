//
//  AppDelegate.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/24/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import UIKit
import SwifteriOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    return true
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    Swifter.handleOpenURL(url)
    
    return true
  }
  
}

