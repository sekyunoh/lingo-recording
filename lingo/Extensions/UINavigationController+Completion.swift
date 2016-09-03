//
//  UINavigationController+Completion.swift
//  lingo
//
//  Created by Taehyun Park on 2/22/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit

extension UINavigationController {
  
  func pushViewController(viewController: UIViewController,
    animated: Bool, completion: (Void -> Void)?) {
      CATransaction.begin()
      if let completion = completion {
        CATransaction.setCompletionBlock(completion)
      }
      pushViewController(viewController, animated: animated)
      CATransaction.commit()
  }
  
}