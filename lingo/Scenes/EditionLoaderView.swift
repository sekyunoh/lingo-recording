//
//  EditionLoaderView.swift
//  lingo
//
//  Created by Taehyun Park on 2/7/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
import Material

class EditionLoaderView: SplashView {
  var progress: UIProgressView!
  var quitButton: FlatButton!
  var retryButton: FlatButton!
  
  convenience init() {
    self.init(frame: UIScreen.mainScreen().bounds)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func initUI() {
    super.initUI()
    
    progress = UIProgressView().then {
      $0.progressViewStyle = .Bar
      $0.tintColor = UIColor.whiteColor()
      $0.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
      $0.hidden = true
    }
    addSubview(progress)
    progress.snp_makeConstraints {
      $0.width.bottom.equalTo(self)
      $0.height.equalTo(20)
    }
    
    quitButton = FlatButton().then {
      $0.setTitle("취소", forState: .Normal)
      $0.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      $0.pulseColor = MaterialColor.lightBlue.lighten1
      $0.hidden = true
    }
    addSubview(quitButton)
    quitButton.snp_makeConstraints {
      $0.height.equalTo(40)
      $0.bottom.equalTo(self).offset(-20)
      $0.left.equalTo(self).offset(10)
      
    }
    
    retryButton = FlatButton().then {
      $0.setTitle("재시도", forState: .Normal)
      $0.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      $0.pulseColor = MaterialColor.lightBlue.lighten1
      $0.hidden = true
    }
    addSubview(retryButton)
    retryButton.snp_makeConstraints {
      $0.height.equalTo(40)
      $0.bottom.equalTo(self).offset(-20)
      $0.right.equalTo(self).offset(-10)
    }
  }
  
  func error() {
    progress.hidden = true
    quitButton.hidden = false
    retryButton.hidden = false
    activityIndicator.hidden = true
  }
  
  func loading() {
    progress.hidden = false
    quitButton.hidden = true
    retryButton.hidden = true
    activityIndicator.hidden = false
    activityIndicator.startAnimating()
  }
  
}
