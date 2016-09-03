//
//  UIUtils.swift
//  lingo
//
//  Created by Taehyun Park on 2/12/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

public let ScreenWidth = UIScreen.mainScreen().bounds.size.width
public let ScreenHeight = UIScreen.mainScreen().bounds.size.height
public let MainBounds = UIScreen.mainScreen().bounds
public let globalTabbarHeight = 49
public let globalNavigationBarHeight = 64
public let globalSizeWithoutNavbarOrTabbar = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - CGFloat(globalTabbarHeight + globalNavigationBarHeight))
public let statusBar = 20



public struct UIUtils {
  public static func beginIgnoringInteractionEvents() {
    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
  }
  
  public static func endIgnoringInteractionEvents() {
    UIApplication.sharedApplication().endIgnoringInteractionEvents()
  }
}