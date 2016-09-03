//
//  Responses.swift
//  lingo
//
//  Created by Taehyun Park on 2/2/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class Response : Mappable, CustomDebugStringConvertible {
  var status: Int!
  var message: String?
  
  
  required init?(_ map: Map) {
    
  }
  
  // Mappable
  func mapping(map: Map) {
    status <- map["status"]
    message <- map["message"]
  }
  
  var debugDescription:String {
    return Mapper().toJSONString(self, prettyPrint: true)!
  }
}

class ObjectResponse<T:Mappable>: Response {
  var data: T?
  
  required init?(_ map: Map) {
    super.init(map)
  }
  
  // Mappable
  override func mapping(map: Map) {
    super.mapping(map)
    data <- map["data"]
  }
}

class ArrayResponse<T:Mappable>: Response {
  var data: [T]?
  
  required init?(_ map: Map) {
    super.init(map)    
  }
  
  // Mappable
  override func mapping(map: Map) {
    super.mapping(map)
    data <- map["data"]
  }
}


//class SerialResponse : Response<Serial> {
//}
//
class TeachersResponse: ArrayResponse<Teacher> {
  
}