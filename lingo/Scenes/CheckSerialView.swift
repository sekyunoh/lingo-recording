//
//  CheckSerialView.swift
//  lingo
//
//  Created by Taehyun Park on 1/4/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
import Material

class CheckSerialView: UIView {
  
  var serialTextField: TextField!
  var checkButton: UIButton!
  
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
    self.backgroundColor = UIColor.whiteColor()
    
    serialTextField = TextField().then {
      $0.placeholder = "제품번호"
      $0.font = RobotoFont.regularWithSize(18)
      $0.keyboardType = .ASCIICapable
      $0.autocapitalizationType = .AllCharacters
      $0.titleLabel = UILabel()
      $0.titleLabel!.font = RobotoFont.mediumWithSize(13)
      $0.titleLabelColor = MaterialColor.grey.lighten1
      $0.titleLabelActiveColor = MaterialColor.blue.accent3
      $0.clearButtonMode = .WhileEditing
      
      $0.detailLabel = UILabel().then {
        $0.text = "올바른 제품번호가 아닙니다."
      }
      $0.detailLabel!.font = RobotoFont.mediumWithSize(12)
      $0.detailLabelActiveColor = MaterialColor.red.accent3
      $0.titleLabelAnimationDistance = 4
      $0.detailLabelAnimationDistance = 4
      $0.returnKeyType = .Done
    }
    
    checkButton = UIButton(type: .System).then {
      $0.setTitle("인증하기", forState: .Normal)
      $0.titleLabel?.font = RobotoFont.mediumWithSize(24)
      $0.enabled = false
    }
    
    addSubview(serialTextField)
    addSubview(checkButton)
    
    serialTextField.snp_makeConstraints {
      $0.top.equalTo(self.snp_centerY).offset(-UI.largePadding)
      $0.left.equalTo(self).offset(UI.defaultPadding)
      $0.right.equalTo(self).offset(-UI.defaultPadding)
    }
    
    checkButton.snp_makeConstraints {
      $0.top.equalTo(serialTextField.snp_bottom).offset(30)
      $0.left.equalTo(self).offset(UI.defaultPadding)
      $0.right.equalTo(self).offset(-UI.defaultPadding)
    }
  }
  
}
