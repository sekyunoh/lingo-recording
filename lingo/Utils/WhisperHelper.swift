//
//  WhisperHelper.swift
//  lingo
//
//  Created by Taehyun Park on 2/11/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import Whisper

public struct Whispers {
  public static func error(message: String, _ navigationController: UINavigationController?) {
    if let navigationController = navigationController {
      show(whisper: Message(title: message, textColor: UIColor.whiteColor(), backgroundColor: App.errorColor), to: navigationController, action: .Show)
    }
  }
  
  public static func info(message: String, _ navigationController: UINavigationController?) {
    if let navigationController = navigationController {
      show(whisper: Message(title: message, textColor: UIColor.whiteColor(), backgroundColor: App.secondaryColor), to: navigationController, action: .Show)
    }
  }
  
  public static func silent(navigationController: UINavigationController?) {
    if let navigationController = navigationController {
        hide(whisperFrom: navigationController)
    }
  }
  
  public static func shout(title: String, message: String, duration: NSTimeInterval = 3, _ viewController: UIViewController?, completion: (() -> ())? = nil) {
    if let viewController = viewController {
        
        show(shout: Announcement(title: title, subtitle: message, image: UIImage(named: "teacher"), duration: duration), to: viewController, completion: completion)
    }
  }
  
  public static func murmur(message: String, duration: NSTimeInterval = 3) {
    show(whistle: Murmur(title: message, backgroundColor: App.primaryColor, titleColor: UIColor.whiteColor()))
    hide(whistleAfter: duration)
  }
}

