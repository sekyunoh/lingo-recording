//
//  ShelfHeaderView.swift
//  lingo
//
//  Created by Taehyun Park on 2/8/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit

class ShelfHeaderView: UIView {

  var logoView: UIImageView!

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
      $0.image = UIImage(named: "sunrin_logo")
    }
    addSubview(logoView)
    logoView.snp_makeConstraints {
      $0.width.height.equalTo(self)
    }
  }
  
}
