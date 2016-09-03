//
//  UIRefreshControl+Rx.swift
//  lingo
//
//  Created by Taehyun Park on 2/12/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//


import UIKit
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif

#if !RX_NO_MODULE
  func bindingErrorToInterface(error: ErrorType) {
    let error = "Binding error to UI: \(error)"
    #if DEBUG
      fatalError(error)
    #else
      print(error)
    #endif
  }
  
#endif

public extension UIRefreshControl {
  public var rx_refreshing: AnyObserver<Bool> {
    return AnyObserver { event in
      MainScheduler.ensureExecutingOnScheduler()
      switch(event) {
      case .Next(let value):
        if value {
          self.beginRefreshing()
        } else {
          self.endRefreshing()
        }
      case .Error(let error):
        bindingErrorToInterface(error)
        break;
      case .Completed:
        break
      }
    }
  }
  
  /**
   Reactive wrapper for `ValueChanged` control event.
   */
  public var rx_changed: ControlEvent<Void> {
    return rx_controlEvent(.ValueChanged)
  }
}