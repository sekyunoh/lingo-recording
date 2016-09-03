//
//  BaseFormViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/12/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger
import Eureka
#if !RX_NO_MODULE
  import RxSwift
#endif


class BaseFormViewController: FormViewController {
  
  var disposeBag = DisposeBag()
  
  var appDelegate: AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
  }
  var log: XCGLogger {
    return appDelegate.log
  }
  
  let $ = Dependencies.instance
  
}