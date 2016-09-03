//
//  ViewController.swift
//  lingo
//
//  Created by Taehyun Park on 12/30/15.
//  Copyright © 2015 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import Foundation
import XCGLogger
#if !RX_NO_MODULE
  import RxSwift
#endif

class ViewController: UIViewController {
  var disposeBag = DisposeBag()
  var appDelegate: AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
  }
  var log: XCGLogger {
    return appDelegate.log
  }
  
  let $ = Dependencies.instance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureActivityIndicatorsShow()
  }
  
  func configureActivityIndicatorsShow() {
    API.instance.loading
      .distinctUntilChanged()
      .driveNext { UIApplication.sharedApplication().networkActivityIndicatorVisible = $0 }
      .addDisposableTo(disposeBag)
  }
}

