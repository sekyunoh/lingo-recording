//
//  ProfileViewController.swift
//  lingo
//
//  Created by Taehyun Park on 1/5/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import XCGLogger
import Eureka
import SwiftyUserDefaults
#if !RX_NO_MODULE
  import RxSwift
#endif
import DeviceKit
import Whisper
import RealmSwift

class ProfileViewController: BaseFormViewController, UITextFieldDelegate {
  var teachers = [Teacher]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "프로필"
    HUD.progress()
    if let user = SessionManager.instance.user {
      guard let email = user["email"] as? String else {
        return
      }
      guard let name = user["name"] as? String else {
        return
      }
      guard let schoolId = user["schoolId"] as? Int else {
        return
      }
      form
        +++ Section("계정 정보")
        <<< LabelRow() {
          $0.title = "이름"
          $0.value = name
        }
        <<< LabelRow() {
          $0.title = "이메일"
          $0.value = email
        }
        <<< ButtonRow() {
          $0.title = "비밀번호 변경"
          }.onCellSelection { cell, row in
            self.changePassword()
      }
    }
    API.instance.teachersByUserId()
      .flatMap { teachers -> Observable<ObjectResponse<Profile>> in
        self.teachers = teachers!
        return API.instance.profile()
      }
      .subscribe(onNext: { response in
        if let profile = response.data where response.status == 200 {
          let selectedTeachers = profile.teachers.map { teacherId -> Teacher? in
            for teacher in self.teachers {
              if teacher.id == teacherId {
                return teacher
              }
            }
            return nil
            }.filter { $0 != nil }.map{ $0! }
          Dispatcher.main {
            self.form
              +++ Section("학생 정보")
              <<< LabelRow() {
                $0.title = "학교"
                $0.value  = "\(profile.school.location) \(profile.school.name)"
              }
              <<< StudentIdPickerInlineRow("studentId") {
                $0.title = "학번"
                $0.elementary = profile.school.grade == "ELEM"
                $0.value = StudentId(studentId: profile.studentId)
              }
              <<< MultipleTeacherSelectorRow("teachers") {
                $0.title = "선생님"
                $0.options = self.teachers
                $0.value  = Set<Teacher>(selectedTeachers)
              }
              +++ Section("")
              <<< ButtonRow() {
                $0.title = "로그아웃"
                }.cellSetup { cell, row in
                  cell.textLabel?.textColor = App.errorColor
                  cell.tintColor = App.errorColor
                }.onCellSelection { cell, row in
                  self.$.wireframe.promptFor(self.navigationController, title: "로그아웃", message: "로그아웃 하시겠습니까?", cancelAction: "취소", actions: ["로그아웃"])
                    .subscribeNext { action in
                      if action == "로그아웃" {
                        Defaults[.userId] = nil
                        Defaults[.user] = nil
                        Defaults[.userId] = nil
                        Defaults[.user] = nil
                        let realm = try! Realm()
                        try! realm.write {
                          realm.deleteAll()
                        }
                        self.presentViewController(UINavigationController(rootViewController: LoginViewController()), animated: true, completion: nil)
                      }
                    }.addDisposableTo(self.disposeBag)
                  
            }
            
            HUD.hide()
          }
        }
        }, onError: { error in
          HUD.error()
          self.log.error("error=\(error)")
      }).addDisposableTo(disposeBag)
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "didClickFinish")
  }
  
  func didClickFinish() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  var alertController: UIAlertController?
  
  func changePassword() {
    if alertController == nil {
      alertController = UIAlertController(title: "비밀번호 변경", message: nil, preferredStyle: .Alert)
      let cancelAction = UIAlertAction(title: "취소", style: .Cancel, handler: nil)
      let changeAction = UIAlertAction(title: "변경", style: .Default) { action in
        self.doPasswordChange((self.alertController!.textFields?.first?.text)!)
      }
      changeAction.enabled = false
      alertController!.addAction(cancelAction)
      alertController!.addAction(changeAction)
      alertController!.addTextFieldWithConfigurationHandler { textField in
        textField.placeholder = "새로운 비밀번호 (6 ~ 30자리)"
        textField.secureTextEntry = true
        textField.delegate = self
      }
      alertController!.addTextFieldWithConfigurationHandler { textField in
        textField.placeholder = "비밀번호 확인"
        textField.secureTextEntry = true
        textField.delegate = self
      }
      alertController!.textFields?.last?.rx_text.subscribeNext { passwordConfirm in
        changeAction.enabled =  passwordConfirm.isValidPassword() && passwordConfirm ==
          self.alertController!.textFields?.first?.text
        }.addDisposableTo(disposeBag)
    }
    
    presentViewController(alertController!, animated: true, completion: nil)
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let passwordTextField = alertController?.textFields?.first, let passwordConfirmTextField = alertController?.textFields?.last {
      if passwordTextField == textField {
        if let password =  passwordTextField.text where password.isValidPassword() {
          textField.resignFirstResponder()
          passwordConfirmTextField.becomeFirstResponder()
        } else {
          Whispers.error("올바른 비밀번호를 입력해 주세요", self.navigationController)
        }
      } else {
        if let passwordConfirm = passwordConfirmTextField.text where passwordConfirm == passwordTextField.text {
          doPasswordChange(passwordConfirm)
          return true
        } else {
          Whispers.error("비밀번호가 일치하지 않습니다.", self.navigationController)
        }
        
      }
      
    }
    return false
  }
  
  func doPasswordChange(password: String) {
    HUD.progress()
    alertController?.textFields?.forEach {
      $0.text = nil
    }
    let form = try! NSJSONSerialization.dataWithJSONObject(["password":password, "rpassword":password], options: [])
    API.instance.changePassword(form).observeOn(MainScheduler.instance).subscribe(onNext: { response in
      if response.status == 200 {
        HUD.success()
        Whispers.info("비밀번호가 변경되었습니다.", self.navigationController)
      } else {
        HUD.error()
        Whispers.info(response.message ?? "비밀번호 변경을 실패하였습니다.", self.navigationController)
      }
      }, onError: { error in
        var message: String?
        if let apiError = error as? APIError {
          switch apiError {
          case let .BadRequest(errorMessage):
            message = errorMessage
          default:
            break
          }
        }
        HUD.error()
        Whispers.error(message ?? "비밀번호 변경을 실패하였습니다.", self.navigationController)
    }).addDisposableTo(disposeBag)
  }
}
