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
    //print(textField.text)//Optional("student@imagevoca.com?")
    if let textField = textField as? TextField {
        
    //email
      if textField.returnKeyType == .Next {
        if textField.text != nil{
            loginView.emailTextField.revealError = false
            //do noting
        }
        if textField.text!.isEmpty {
            
            loginView.emailTextField.detail = "이메일을 입력해 주세요."
            loginView.emailTextField.revealError = true
            textField.clearButtonMode = .WhileEditing
          return false
        }
        
        if !textField.text!.isValidEmail() {
          
          loginView.emailTextField.detail = "올바른 이메일을 입력해 주세요."
          loginView.emailTextField.revealError = true
            return false
        }
        
        
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
   
    if loginView.emailTextField.text != nil && loginView.emailTextField.text!.isValidEmail(){
        loginView.emailTextField.revealError = false
        //do nothing
    }
   
    
    if loginView.emailTextField.text!.isEmpty {
    
      loginView.emailTextField.detail = "이메일을 입력해 주세요."
      loginView.emailTextField.revealError = true
      return
    }
    
    if !loginView.emailTextField.text!.isValidEmail() {
      loginView.emailTextField.detail = "올바른 이메일을 입력해 주세요."
      loginView.emailTextField.revealError = true
      return
    }
    
    //이메일을 올바르게 입력하고 비밀번호를 아무것도 안쓰고 엔터(혹은 로긴버튼)치면 이게 실행
    if loginView.passwordTextField.text != nil {
        loginView.passwordTextField.revealError = false
        //do nothing
    }
    
    if (loginView.passwordTextField.text!.isEmpty && !loginView.emailTextField.text!.isEmpty){
      loginView.passwordTextField.detail = "비밀번호를 입력해주세요."
      loginView.passwordTextField.revealError = true
      return
    }
    //이메일을 올바르게 입력하고 비밀번호를 5자리이하 엔터(혹은 로긴버튼)치면 이게 실행
    if !loginView.passwordTextField.text!.isValidPassword() {
      loginView.passwordTextField.detail = "올바른 비밀번호를 입력해주세요."
      loginView.passwordTextField.revealError = true
      return
    }
//    loginView.passwordTextField.detailLabelHidden = true
    //HUD.progress()
    API.instance.login([
        
      //"email":email,
      //"password":password,
      "email":loginView.emailTextField.text!,
      "password":loginView.passwordTextField.text!,
      "device":currentDevice
      ]).subscribeOn($.backgroundWorkScheduler)
      .subscribe(onNext: { [weak self] response in
        guard let SELF = self else {
          HUD.progress()
          //여기다 놓으면 비번,이멜 일치하면 HUD 나오고 일치안하면 밑에 로그인실패 alert뜸!
          return
        }
        if let authUser = response.data  where response.status == 200 {
          let loggedInUser: [String: AnyObject] = [
            "id": authUser.id,
            "grade": authUser.grade,
            "role": authUser.role,
            //"email": email,
            "email":self!.loginView.emailTextField.text!,
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
            
          /*HUD.error()
          if let message = response.message {
            Whispers.error(message, self?.navigationController)
          } else {
            Whispers.error("로그인에 실패하였습니다. 잠시 후 다시 시도해 주세요.", self?.navigationController)
          }*/
        }
        }, onError: { error in
            HUD.hide(true)
            let alertView = UIAlertController(title: "로그인 실패!", message: "", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.Cancel) { _ in
                })
            self.presentViewController(alertView, animated: true, completion: nil)
          //HUD.error()
          print("errorrrrr\(error)")
      })
      .addDisposableTo(disposeBag)
  }
  
  deinit {
    self.log.debug("Deinit LoginViewController")
  }
}
