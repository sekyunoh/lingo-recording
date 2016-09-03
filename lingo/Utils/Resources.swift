//
//  Resources.swift
//  lingo
//
//  Created by Taehyun Park on 2/13/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import XCGLogger

public struct Resources {
  
  public static func path(name: String) -> String {
    let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    return documentPath + "/\(name).obb"
  }
  
  public static func url(name: String) -> NSURL {    
    return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("\(name).obb")
  }
  
  public static func exists(name: String) -> Bool {
    return NSFileManager.defaultManager().fileExistsAtPath(path(name))
  }
  
  public static func remove(name: String) {
    do{
      try NSFileManager.defaultManager().removeItemAtPath(path(name))
    } catch let error as NSError {
      print(error.localizedDescription)
    }
    
  }
  
  public static func size(name: String) -> Int {
    do {
      let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(path(name))
      
      if let _attr = attr {
        return Int(_attr.fileSize());
      }
    } catch {
      print("Error: \(error)")
    }
    return -1
  }  
}