//
//  SplashView.swift
//  lingo
//
//  Created by Taehyun Park on 2/3/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit

class SplashView: UIView {
  var activityIndicator: UIActivityIndicatorView!
  var logoImage: UIImageView!
  var messageLabel: UILabel!
  
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
  
  func initUI() {
    self.backgroundColor = App.primaryColor
    
    logoImage = UIImageView().then {
      $0.image = UIImage(named: "LaunchScreen")
      $0.contentMode = .Center
    }
    addSubview(logoImage)
    
    logoImage.snp_makeConstraints {
      $0.center.equalTo(self)
    }
    
    messageLabel = UILabel().then {
      $0.textColor = UIColor.whiteColor()
      $0.textAlignment = .Center
      $0.adjustsFontSizeToFitWidth = false
      $0.numberOfLines = 0
      $0.lineBreakMode = .ByWordWrapping
    }
    addSubview(messageLabel)
    messageLabel.snp_makeConstraints {
      $0.width.equalTo(self)
      $0.centerX.equalTo(self)
      $0.top.equalTo(logoImage.snp_bottom).offset(40)
    }
    
    activityIndicator = UIActivityIndicatorView().then {
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.activityIndicatorViewStyle = .WhiteLarge
    }
    addSubview(activityIndicator)
    activityIndicator.startAnimating()
    activityIndicator.snp_makeConstraints {
      $0.centerX.equalTo(self)
      $0.bottom.equalTo(self).offset(-80)
    }
    

    
  }

}
