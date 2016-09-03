//
//  UIImageView+Word.swift
//  lingo
//
//  Created by Taehyun Park on 2/15/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
  import RxSwift
#endif


public extension UIImageView {
  public func iv_setImageWithFilename(filename: String) -> Disposable?  {
    if let editionManager = SessionManager.instance.editionManager {
    return editionManager.image(filename).driveNext { image in
        self.image = image
      }
    }
    return nil
  }
  
}