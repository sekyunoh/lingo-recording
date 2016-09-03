//
//  LearningNavigationViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/25/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
  import RxSwift
#endif
import XCGLogger

class LearningNavigationViewController: UINavigationController {
  let $ = Dependencies.instance
  var disposeBag = DisposeBag()
  var appDelegate: AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
  }
  
  var log: XCGLogger {
    return appDelegate.log
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    log.debug("viewdidLoad")
    // Do any additional setup after loading the view.
  }
  

  

  
}
