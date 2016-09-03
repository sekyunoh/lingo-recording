//
//  NSDates.swift
//  lingo
//
//  Created by Taehyun Park on 3/13/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation



func NSDateTimeAgoLocalizedStrings(key: String) -> String {
  let resourcePath: String?
  
  if let frameworkBundle = NSBundle(identifier: "com.kevinlawler.NSDateTimeAgo") {
    // Load from Framework
    resourcePath = frameworkBundle.resourcePath
  } else {
    // Load from Main Bundle
    resourcePath = NSBundle.mainBundle().resourcePath
  }
  
  if resourcePath == nil {
    return ""
  }
  
  let path = NSURL(fileURLWithPath: resourcePath!).URLByAppendingPathComponent("NSDateTimeAgo.bundle")
  guard let bundle = NSBundle(URL: path) else {
    return ""
  }
  
  return NSLocalizedString(key, tableName: "NSDateTimeAgo", bundle: bundle, comment: "")
}

extension NSDate {
  
  // shows 1 or two letter abbreviation for units.
  // does not include 'ago' text ... just {value}{unit-abbreviation}
  // does not include interim summary options such as 'Just now'
  public var timespan: String {
    let components = self.dateComponents()
    let postfix = self < NSDate() ? "전" : "후"
    
    let year = abs(components.year)
    if year > 0 {
      return "\(year)년 \(postfix)"
    }
    
    
    let month = abs(components.month)
    if month > 0 {
      return "\(month)달 \(postfix)"
    }
    
    let day = abs(components.day)
    if day >= 7 {
      let value = day/7
      return "\(value)주 전"
    }
    
    if day > 0 {
      return "\(day)일 \(postfix)"
    }
    
    let hour = abs(components.hour)
    if hour > 0 {
      return "\(hour)시간 \(postfix)"
    }
    
    let minute = abs(components.minute)
    if minute > 0 {
      return "\(minute)분 \(postfix)"
    }
    
    let second = abs(components.second)
    if second > 0 {
      return "\(second)초 \(postfix)"
    }
    
    return "방금"
  }
  
  private func dateComponents() -> NSDateComponents {
    let calander = NSCalendar.currentCalendar()
    return calander.components([.Second, .Minute, .Hour, .Day, .Month, .Year], fromDate: self, toDate: NSDate(), options: [])
  }
}



public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }