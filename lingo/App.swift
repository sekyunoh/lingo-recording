//
//  App.swift
//  lingo
//
//  Created by Taehyun Park on 2/1/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

let debug = false

struct App {
  static let windowBackgroundColor = UIColor.whiteColor()

  // #BBDEFB md-blud-100
  static let lightColor = UIColor(red: 187/255, green: 222/255, blue: 251/255, alpha: 1)
  
  // #2196F3 md-blue-500
  static let primaryColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1)
  
  // #1976D2 md-blue-700
  static let secondaryColor = UIColor(red: 25/255, green: 118/255, blue: 210/255, alpha: 1)
  
  static let tintColor = primaryColor
  
  //  static let endPoint = "http://192.168.1.2:9000"
  static let resource = "http://dev.imagevoca.com"
  static let endPoint = resource
  
  // #F44336 md-red-a200
  static let errorColor = UIColor(red: 255/255, green: 82/255, blue: 82/255, alpha: 1)
  
  // #448AFF md-blue-a200
  static let successColor = UIColor(red: 68/255, green: 138/255, blue: 255/255, alpha: 1)
  
  struct Title {
    static let learning = "학습"
    static let review = "복습"
    static let flashcards = "플래시 카드"
    static let quiz = "시험"
    static let settings = "설정"
  }
  
  static let version = 1
}


struct Theme {
  static let learning = App.primaryColor
  static let quiz = UIColor(red: 103/255, green: 58/255, blue: 255/255, alpha: 1)
  static let flashcards = App.secondaryColor
  static let review = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
}
