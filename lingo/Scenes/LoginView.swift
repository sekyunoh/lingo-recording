//
//  LoginScreenView.swift
//  lingo
//
//  Created by Taehyun Park on 12/30/15.
//  Copyright © 2015 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
import Material

class LoginView: UIView {
  
  
  
  var emailTextField: ErrorTextField!
  var passwordTextField: ErrorTextField!
  var forgotPasswordButton: FlatButton!
  
  var signinButton: UIButton!
  var signupButton: UIButton!
  
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
    self.backgroundColor = UIColor.cyanColor()
    
    let tapper = UITapGestureRecognizer(target: self, action: #selector(LoginView.dismissKeyboard))
    tapper.cancelsTouchesInView = false
    addGestureRecognizer(tapper)
    
    emailTextField = ErrorTextField().then {
      $0.placeholder = "이메일"
      $0.font = RobotoFont.regularWithSize(18)
      $0.keyboardType = .EmailAddress
      $0.autocorrectionType = .No
      $0.autocapitalizationType = .None
      //      $0.titleLabel!.font = RobotoFont.mediumWithSize(13)
      //      $0.titleLabelColor = MaterialColor.grey.lighten1
      //      $0.titleLabelActiveColor = MaterialColor.blue.accent3
      $0.clearButtonMode = .WhileEditing
      
      //$0.detail = "올바른 이메일을 입력해주세요."
      
      $0.returnKeyType = .Next
//      $0.detailLabelActiveColor = MaterialColor.red.accent3
//      $0.titleLabelAnimationDistance = 4
//      $0.detailLabelAnimationDistance = 4
    }
    passwordTextField = ErrorTextField().then {
      $0.placeholder = "비밀번호"
      $0.secureTextEntry = true
      $0.font = RobotoFont.regularWithSize(18)
//      $0.titleLabel = UILabel()
//      $0.titleLabel!.font = RobotoFont.mediumWithSize(13)
//      $0.titleLabelColor = MaterialColor.grey.lighten1
//      $0.titleLabelActiveColor = MaterialColor.blue.accent3
      $0.clearButtonMode = .WhileEditing
      $0.returnKeyType = .Done
//      $0.detailLabel = UILabel().then {
//        $0.font = RobotoFont.mediumWithSize(12)
//        $0.text = "비밀번호를 입력해주세요."
//      }
//      $0.detailLabelActiveColor = MaterialColor.red.accent3
//      $0.titleLabelAnimationDistance = 4
//      $0.detailLabelAnimationDistance = 4
    }
    
    forgotPasswordButton = FlatButton(type: .System).then {
      $0.setTitle("비밀번호 분실", forState: .Normal)
      $0.setTitleColor(self.tintColor, forState: .Normal)
    }
    
    signinButton = RaisedButton(type: .System).then {
      $0.setTitle("로그인", forState: .Normal)
      $0.titleLabel?.font = RobotoFont.mediumWithSize(24)
    }
    
    signupButton = RaisedButton(type: .System).then {
      $0.setTitle("회원 가입", forState: .Normal)
      $0.titleLabel?.font = RobotoFont.mediumWithSize(24)
    }
    
    addSubview(emailTextField)
    addSubview(passwordTextField)
    addSubview(forgotPasswordButton)
    
    addSubview(signinButton)
    addSubview(signupButton)
    
    
    emailTextField.snp_makeConstraints {
      $0.top.equalTo(self.snp_centerY).offset(-50)
      $0.left.equalTo(self).offset(UI.largePadding)
      $0.right.equalTo(self).offset(-UI.largePadding)
    }
    
    passwordTextField.snp_makeConstraints {
      $0.top.equalTo(emailTextField.snp_bottom).offset(52)
      $0.left.equalTo(emailTextField)
      $0.right.equalTo(emailTextField)
    }
    
    forgotPasswordButton.snp_makeConstraints {
      $0.top.equalTo(passwordTextField.snp_bottom).offset(UI.largePadding)
      $0.right.equalTo(emailTextField)
    }
    
    signinButton.snp_makeConstraints {
      $0.top.equalTo(forgotPasswordButton.snp_bottom).offset(UI.largePadding)
      $0.left.equalTo(emailTextField)
      $0.right.equalTo(emailTextField)
    }
    
    signupButton.snp_makeConstraints {
      $0.top.equalTo(signinButton.snp_bottom).offset(UI.largePadding)
      $0.left.equalTo(emailTextField)
      $0.right.equalTo(emailTextField)
    }
  }
  
  func dismissKeyboard() {
    emailTextField.endEditing(true)
    passwordTextField.endEditing(true)
  }
  
}
