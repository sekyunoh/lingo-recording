//
//  Dispatcher.swift
//  lingo
//
//  Created by Taehyun Park on 2/29/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation

let apiQueue: dispatch_queue_t = dispatch_queue_create("restQueue", DISPATCH_QUEUE_CONCURRENT)


struct Dispatcher {
  
  static func worker(action: () -> ()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), action)
  }

  static func main(action: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), action)
  }
}
