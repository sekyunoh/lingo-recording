//
//  HeaderView.swift
//  Shelf
//
//  Created by Hirohisa Kawasaki on 8/10/15.
//  Copyright (c) 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class HeaderView: UIView {

  
  private var logoView: UIImageView!
  
  init(){
    super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 120))
    initUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func initUI() {
    logoView = UIImageView().then {
      $0.contentMode = .ScaleAspectFit
    }
    addSubview(logoView)
    logoView.snp_makeConstraints {
      $0.width.height.equalTo(self)
    }
  }

  func setLogo(schoolId: Int) {
    logoView.kf_setImageWithURL(NSURL(string: "\(App.endPoint)/school/\(schoolId)/logo")!)
  }
}