//
//  HUD.swift
//  lingo
//
//  Created by Taehyun Park on 2/11/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//


import Foundation
import PKHUD

public struct HUD {
  public static func progress(userInteraction : Bool = false) {
    PKHUD.sharedHUD.contentView = PKHUDProgressView()
    PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = userInteraction
    PKHUD.sharedHUD.show()
  }
  
  public static func message(message: String, userInteraction : Bool = false) {
    PKHUD.sharedHUD.contentView = PKHUDTextView(text: message)
    PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = userInteraction
    PKHUD.sharedHUD.show()
  }
  
  public static func success(delay: NSTimeInterval = 0.5) {
    PKHUD.sharedHUD.contentView = PKHUDSuccessView()
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.hide(afterDelay: delay)
  }
  
  public static func error(delay: NSTimeInterval = 0.5) {
    PKHUD.sharedHUD.contentView = PKHUDErrorView()
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.hide(afterDelay: delay)
  }
  
  public static func hide(animated: Bool = true) {
    PKHUD.sharedHUD.hide(animated: animated)
  }
}