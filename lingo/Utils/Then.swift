//
//  Then.swift
//  lingo
//
//  Created by Taehyun Park on 12/30/15.
//  Copyright © 2015 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation

public protocol Then {}
extension Then {
  
  func then(block: Self -> Void) -> Self {
    block(self)
    return self
  }
  
}

extension NSObject: Then {}

