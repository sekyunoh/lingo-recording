//
//  LauncherView.swift
//  lingo
//
//  Created by Taehyun Park on 1/5/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit

class LauncherView: UIView {
  var logoView: UIImageView!
  var shelfView: ShelfView!
  
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
  
  private func initUI() {
    backgroundColor = App.windowBackgroundColor
    logoView = UIImageView().then {
      $0.contentMode = .ScaleAspectFit
    }
    addSubview(logoView)
    logoView.snp_makeConstraints {
      $0.width.equalTo(self)
      $0.top.equalTo(self).offset(globalNavigationBarHeight)
      $0.height.equalTo(120)
    }
    let shelfViewHeight = CGFloat(Int(UIScreen.mainScreen().bounds.height) - 120 - globalNavigationBarHeight)
    shelfView = ShelfView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: shelfViewHeight))
    addSubview(shelfView)
    shelfView.snp_makeConstraints {
      $0.top.equalTo(logoView.snp_bottom)
      $0.bottom.width.equalTo(self)
    }
  }
  
  func setLogo(schoolId: Int) {
    logoView.kf_setImageWithURL(NSURL(string: "\(App.resource)/school/\(schoolId)/logo")!)
  }
  
}
