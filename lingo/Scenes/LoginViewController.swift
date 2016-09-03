//
//  LoginScreenViewController.swift
//  lingo
//
//  Created by Taehyun Park on 12/30/15.
//  Copyright © 2015 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import Material
import SwiftyUserDefaults

class LoginViewController: ViewController, TextFieldDelegate {
  
  override func loadView() {
    super.loadView()
    view = LoginView(frame: UIScreen.mainScreen().bounds)
  }
  
  var loginView: LoginView {
    return self.view as! LoginView
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBarHidden = true
    self.title = "로그인"
    let view = self.view as! LoginView
    view.emailTextField.delegate = self
    view.passwordTextField.delegate = self
    view.signupButton.rx_tap
      .subscribeNext(showSignup).addDisposableTo(disposeBag)
    view.signinButton.rx_tap
      .subscribeNext(doLogin).addDisposableTo(disposeBag)
    //    HUD.progress(true)
    view.emailTextField.text = "student@imagevoca.com"
    view.passwordTextField.text = "123456"
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBarHidden = true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func showSignup() {
    self.navigationController?.pushViewController(CheckSerialViewController(), animated: true)
  }
  
  /// Executed when the 'return' key is pressed when using the emailField.
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let textField = textField as? TextField {
      if textField.returnKeyType == .Next {
        guard let email = textField.text else {
          textField.detailLabelHidden = false
          textField.detailLabel?.text = "이메일을 입력해 주세요."
          return false
        }
        
        if !email.isValidEmail() {
          textField.detailLabelHidden = false
          textField.detailLabel?.text = "올바른 이메일을 입력해 주세요."
          return false
        }
        textField.detailLabelHidden = true
        
        textField.resignFirstResponder()
        loginView.passwordTextField.becomeFirstResponder()
        return true
      } else {
        doLogin()
      }
    }
    return false
  }
  
  
  
  func doLogin() {
    guard let email = loginView.emailTextField.text else {
      loginView.emailTextField.detailLabelHidden = false
      loginView.emailTextField.detailLabel?.text = "이메일을 입력해 주세요."
      return
    }
    
    if !email.isValidEmail() {
      loginView.emailTextField.detailLabelHidden = false
      loginView.emailTextField.detailLabel?.text = "올바른 이메일을 입력해 주세요."
      return
    }
    
    loginView.emailTextField.detailLabelHidden = true
    
    guard let password = loginView.passwordTextField.text else {
      loginView.passwordTextField.detailLabel?.text = "비밀번호를 입력해주세요."
      loginView.passwordTextField.detailLabelHidden = false
      return
    }
    
    if !password.isValidPassword() {
      loginView.passwordTextField.detailLabel?.text = "올바른 비밀번호를 입력해주세요."
      loginView.passwordTextField.detailLabelHidden = false
      return
    }
    loginView.passwordTextField.detailLabelHidden = true
    HUD.progress()
    API.instance.login([
      "email":email,
      "password":password,
      "device":currentDevice
      ]).subscribeOn($.backgroundWorkScheduler)
      .subscribe(onNext: { [weak self] response in
        guard let SELF = self else {
          return
        }
        if let authUser = response.data where response.status == 200 {
          let loggedInUser: [String: AnyObject] = [
            "id": authUser.id,
            "grade": authUser.grade,
            "role": authUser.role,
            "email": email,
            "name": authUser.name,
            "gender": authUser.gender,
            "schoolId": authUser.schoolId
          ]
          Defaults[.userId] = authUser.id
          Defaults[.token] = authUser.token
          Defaults[.role] = authUser.role
          Defaults[.grade] = authUser.grade
          Defaults[.user] = loggedInUser
          SessionManager.instance.token = authUser.token
          SessionManager.instance.user = loggedInUser
          SessionManager.instance.userId = authUser.id
          dispatch_async(dispatch_get_main_queue()){
            SELF.presentViewController(UINavigationController(rootViewController: LauncherViewController()), animated: false) {
              DefaultWireframe.rootViewController()
            }
//            DefaultWireframe.switchRootViewController(UINavigationController(rootViewController: LauncherViewController()), animated: true, completion: nil)
          }
        }else {
          HUD.error()
          if let message = response.message {
            Whispers.error(message, self?.navigationController)
          } else {
            Whispers.error("로그인에 실패하였습니다. 잠시 후 다시 시도해 주세요.", self?.navigationController)
          }
        }
        }, onError: { error in
          HUD.error()
          print(error)
      })
      .addDisposableTo(disposeBag)
  }
  
  deinit {
    self.log.debug("Deinit LoginViewController")
  }
}
