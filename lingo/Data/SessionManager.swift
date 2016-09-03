//
//  SessionManager.swift
//  lingo
//
//  Created by Taehyun Park on 2/3/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
//import objective_zip

class SessionManager {
  static let instance = SessionManager()

  var userId: Int?
  var token: String?
  var editionManager: EditionManager?
  var user: [String: AnyObject]?
}