//
//  ListTransform.swift
//  lingo
//
//  Created by Taehyun Park on 2/12/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyJSON


class ListTransform<T:RealmSwift.Object where T:Mappable> : TransformType {
  typealias Object = List<T>
  typealias JSON = [AnyObject]
  
  let mapper = Mapper<T>()
  
  func transformFromJSON(value: AnyObject?) -> Object? {
    var results = List<T>()
    if let value = value as? [AnyObject] {
      for json in value {
        if let obj = mapper.map(json) {
          results.append(obj)
        }
      }
    }
    return results
  }
  
  func transformToJSON(value: Object?) -> JSON? {
    var results = [AnyObject]()
    if let value = value {
      for obj in value {
        let json = mapper.toJSON(obj)
        results.append(json)
      }
    }
    return results
  }
}


public class BetterDateTransform: DateTransform {
  
  public override init() {
    super.init()
  }
  
  override public func transformFromJSON(value: AnyObject?) -> NSDate? {
    if let timeInt = value as? Double {
      return NSDate(timeIntervalSince1970: NSTimeInterval(timeInt/1000))
    }
    
    if let timeStr = value as? String {
      return NSDate(timeIntervalSince1970: NSTimeInterval(atof(timeStr)))
    }
    
    return nil
  }
  
  override public func transformToJSON(value: NSDate?) -> Double? {
    if let date = value {
      return Double(date.timeIntervalSince1970*1000)
    }
    return nil
  }
}
