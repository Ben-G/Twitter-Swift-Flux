//
//  ImageDownload.swift
//  TwitterLivestreamSwift
//
//  Created by Benjamin Encz on 1/26/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

func fetchImage(urlString:String) -> Promise<UIImage> {
  let fileName = filenameForURLString(urlString)
  if (NSFileManager.defaultManager().fileExistsAtPath(fileName.absoluteString!)) {
    return Promise { (fulfill, _) in
      let image = UIImage(contentsOfFile: fileName.absoluteString!)!
      fulfill(image)
    }
  }
  
  return Promise { (fulfill, reject) in
    Alamofire.download(.GET, urlString, { (temporaryURL, response) in
    
      let url = filenameForURLString(urlString)
      let imageData = NSData(contentsOfURL:url)
      
      if let imageData = imageData {
        let image = UIImage(data: imageData)
          if let image = image {
            fulfill(image)
          } else {
            reject(NSError(domain: "", code: 0, userInfo: nil))
          }
        } else {
          reject(NSError(domain: "", code: 0, userInfo: nil))
        }
            
        return url
    })
    
    return
  }
}

private func filenameForURLString(urlString:String) -> NSURL {
  let fileNameComponents = urlString.componentsSeparatedByString("/")
  
  let directoryURL = NSFileManager.defaultManager()
    .URLsForDirectory(.DocumentDirectory,
      inDomains: .UserDomainMask)[0]
    as NSURL
  
  let fileName = fileNameComponents[fileNameComponents.count - 2] + fileNameComponents[fileNameComponents.count - 1]
  let pathComponent = fileName
  let url = directoryURL.URLByAppendingPathComponent(pathComponent)
  
  
  return url
}