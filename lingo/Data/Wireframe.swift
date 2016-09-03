//
//  Wireframe.swift
//  Example
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
  import RxSwift
#endif
import UIKit

enum RetryResult {
  case Retry
  case Cancel
}
//
//protocol Wireframe {
//  func openURL(URL: NSURL)
//  func promptFor<Action: CustomStringConvertible>(message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>
//}
//

class DefaultWireframe {
  static let sharedInstance = DefaultWireframe()
  
  func openURL(URL: NSURL) {
    UIApplication.sharedApplication().openURL(URL)
    
  }
  
  
  static func rootViewController() -> UIViewController {
    // cheating, I know
    return UIApplication.sharedApplication().keyWindow!.rootViewController!
  }
  
  static func presentAlert(title: String = "이미지 보카", message: String) {
    let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    alertView.addAction(UIAlertAction(title: "확인", style: .Cancel) { _ in
      })
    rootViewController().presentViewController(alertView, animated: true, completion: nil)
  }
  
  func promptFor<Action : CustomStringConvertible>(vc: UIViewController?, title: String = "이미지 보카", message: String, cancelAction: Action?, actions: [Action]) -> Observable<Action> {
    return Observable.create { observer in
      let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
      if cancelAction != nil {
      alertView.addAction(UIAlertAction(title: cancelAction!.description, style: .Cancel) { _ in
        observer.on(.Next(cancelAction!))
        })
      }
      
      for action in actions {
        alertView.addAction(UIAlertAction(title: action.description, style: .Default) { _ in
          observer.on(.Next(action))
          })
      }
      if let vc = vc {
        vc.presentViewController(alertView, animated: true, completion: nil)
      }else {
        DefaultWireframe.rootViewController().presentViewController(alertView, animated: true, completion: nil)
      }
      return AnonymousDisposable {
        alertView.dismissViewControllerAnimated(false, completion: nil)
      }
    }
  }
  
  static func switchRootViewController(rootViewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
    //        if let window = UIApplication.sharedApplication().keyWindow {
    //          if animated {
    //            UIView.transitionWithView(window, duration: 0.5, options: .TransitionCrossDissolve, animations: {
    //              let oldState: Bool = UIView.areAnimationsEnabled()
    //              UIView.setAnimationsEnabled(false)
    //              window.rootViewController = rootViewController
    ////              window.makeKeyAndVisible()
    //              UIView.setAnimationsEnabled(oldState)
    //              }, completion: { (finished: Bool) -> () in
    //                if (completion != nil) {
    //                  completion!()
    //                }
    //            })
    //          } else {
    //            window.rootViewController = rootViewController
    ////            window.makeKeyAndVisible()
    //          }
    //        }
    //
    if let window = UIApplication.sharedApplication().keyWindow {
      window.rootViewController?.presentViewController(rootViewController, animated: false, completion: { finished in
        if completion != nil {
          completion!()
        }
        //        window.rootViewController = rootViewController
        //        window.makeKeyAndVisible()
      })
    }
    //      if animated {
    //
    //        UIView.transitionWithView(window, duration: 0.5, options: .TransitionCrossDissolve, animations: {
    //          let oldState: Bool = UIView.areAnimationsEnabled()
    //          UIView.setAnimationsEnabled(false)
    //          window.rootViewController = rootViewController
    //          window.makeKeyAndVisible()
    //          UIView.setAnimationsEnabled(oldState)
    //          }, completion: { (finished: Bool) -> () in
    //            if (completion != nil) {
    //              HUD.hide(false)
    //              completion!()
    //            }
    //        })
    //      } else {
    //        window.rootViewController = rootViewController
    //        window.makeKeyAndVisible()
    //      }
  }
  
  
}

extension UIWindow {
  
  /// Fix for http://stackoverflow.com/a/27153956/849645
  func setRootViewController(newRootViewController: UIViewController, transition: CATransition? = nil) {
    
    let previousViewController = rootViewController
    
    if let transition = transition {
      // Add the transition
      layer.addAnimation(transition, forKey: kCATransition)
    }
    
    rootViewController = newRootViewController
    
    // Update status bar appearance using the new view controllers appearance - animate if needed
    if UIView.areAnimationsEnabled() {
      UIView.animateWithDuration(CATransaction.animationDuration()) {
        newRootViewController.setNeedsStatusBarAppearanceUpdate()
      }
    } else {
      newRootViewController.setNeedsStatusBarAppearanceUpdate()
    }
    
    /// The presenting view controllers view doesn't get removed from the window as its currently transistioning and presenting a view controller
    if let transitionViewClass = NSClassFromString("UITransitionView") {
      for subview in subviews where subview.isKindOfClass(transitionViewClass) {
        subview.removeFromSuperview()
      }
    }
    if let previousViewController = previousViewController {
      // Allow the view controller to be deallocated
      previousViewController.dismissViewControllerAnimated(false) {
        // Remove the root view in case its still showing
        previousViewController.view.removeFromSuperview()
      }
    }
  }
}


extension RetryResult : CustomStringConvertible {
  var description: String {
    switch self {
    case .Retry:
      return "Retry"
    case .Cancel:
      return "Cancel"
    }
  }
}