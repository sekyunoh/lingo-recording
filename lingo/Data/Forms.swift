//
//  Forms.swift
//  lingo
//
//  Created by Taehyun Park on 2/2/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

class LoginForm : Mappable {
  var email: String!
  var password: String!
  
  required init?(_ map: Map) {
    
  }
  
  func mapping(map: Map) {
    
  }
}