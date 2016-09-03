//
//  SignupViewController.swift
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
import AdSupport

class SignupViewController: BaseFormViewController {
  let serial: Serial
  var teachers = [Teacher]()
  
  init(serial: Serial) {
    self.serial = serial
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.log.debug("selected serial=\(serial)")
    title = "회원가입"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "didClickSignup:")
    setupForm()
  }
  
  private func setupForm() {
    
    let displayValue: String = {
      switch serial.securityRole {
      case "student":
        return "학생"
      case "teacher":
        return "선생님"
      case "admin":
        return "관리자"
      default:
        return "알수없음"
      }
    }()
    form
      +++ Section("인증 정보")
      <<< LabelRow() {
        $0.title = "이용권한"
        $0.value = displayValue
      }
      <<< LabelRow() {
        $0.title = "제품번호"
        $0.value = self.serial.serial
      }
      
      +++ Section("계정 정보")
      <<< EmailRow("email") {
        $0.title = "이메일"
        $0.placeholder = "아이디로 사용됩니다."
      }
      <<< PasswordRow("password") {
        $0.title = "비밀번호"
        $0.placeholder = "6 ~ 30자리"
      }
      <<< PasswordRow("passwordConfirm") {
        $0.title = "비밀번호 확인"
      }
      
      +++ Section("학생 정보")
      <<< LabelRow() {
        $0.title = "학교"
        $0.value = "\(self.serial.school.name) (\(self.serial.school.location))"
      }
      <<< SegmentedRow<String>("gender") {
        $0.title = "성별"
        $0.options = ["남자", "여자"]
      }
      <<< TextRow("name") {
        $0.title =  "이름"
      }
      <<< StudentIdPickerInlineRow("studentId") {
        $0.title = "학번"
        $0.elementary = self.serial.school.grade == "ELEM"
        $0.value = StudentId()
      }
      <<< MultipleTeacherSelectorRow("teachers") {
        $0.title = "선생님"
        $0.options = teachers
        }
        
        .onPresent { from, to in
          to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: from, action: "multipleTeacherSelectorDone:")
      }
      +++ Section("이용 약관")
      <<< SwitchRow("agreeAll") {
        $0.title = "전체 동의"
        $0.hidden = .Function(["tos", "privacy"], { form -> Bool in
          if let tosRow: RowOf<Bool> = form.rowByTag("tos"),let privacyRow: RowOf<Bool> = form.rowByTag("privacy") {
            return (tosRow.value ?? false && privacyRow.value ?? false)
          }
          return false
        })
      }
      <<< SwitchRow("tos") {
        $0.title = "이미지 보카 이용 약관"
        $0.hidden = .Function(["agreeAll"], { form -> Bool in
          let agreeAllRow: RowOf<Bool>! = form.rowByTag("agreeAll")
          return agreeAllRow.value ?? false == true
        })
        }.onCellSelection({ cell, row in
          UIApplication.sharedApplication().openURL(NSURL(string: "\(App.endPoint)/signin/agreement?which=TOS")!)
        })
      
      <<< SwitchRow("privacy") {
        $0.title = "개인정보 수집 및 이용"
        $0.hidden = .Function(["agreeAll"], { form -> Bool in
          let agreeAllRow: RowOf<Bool>! = form.rowByTag("agreeAll")
          return agreeAllRow.value ?? false == true
        })
        }.onCellSelection({ cell, row in
          UIApplication.sharedApplication().openURL(NSURL(string: "\(App.endPoint)/signin/agreement?which=PRIVACY")!)
        })
    
    
    
    
    API.instance.teachersBySchoolId(serial.schoolId)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { teachers in
        self.log.debug("teachers=\(teachers)")
        if let teachersRow = self.form.rowByTag("teachers") as? MultipleTeacherSelectorRow, let teachers = teachers {
          teachersRow.options = teachers
          self.log.debug("update options")
        }
      }).addDisposableTo(disposeBag)
  }
  
  func multipleTeacherSelectorDone(item:UIBarButtonItem) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  func didClickSignup(item: UIBarButtonItem) {
    // validate inputs
    let values = self.form.values()
    
    guard let email = values["email"] as? String else {
      Whispers.error("이메일을 입력해 주세요", self.navigationController)
      return
    }
    
    if !email.isValidEmail() {
      Whispers.error("올바른 이메일이 아닙니다", self.navigationController)
      return
    }
    
    guard let password = values["password"] as? String else {
      Whispers.error("비밀번호를 입력해 주세요", self.navigationController)
      return
    }
    
    if !password.isValidPassword() {
      Whispers.error("6 ~ 30자리의 비밀번호를 입력해 주세요", self.navigationController)
      return
    }
    
    guard let passwordConfirm = values["passwordConfirm"] as? String else {
      Whispers.error("비밀번호 확인을 입력해 주세요", self.navigationController)
      return
    }
    
    if password != passwordConfirm {
      Whispers.error("비밀번호가 일치하지 않습니다", self.navigationController)
      return
    }
    
    guard let rawGender = values["gender"] as? String else {
      Whispers.error("성별을 선택해 주세요", self.navigationController)
      return
    }
    
    let gender = rawGender == "남자" ? "MALE" : "FEMALE"
    
    guard let name = values["name"] as? String else {
      Whispers.error("이름을 입력해 주세요", self.navigationController)
      return
    }
    
    guard let studentId = values["studentId"] as? StudentId else {
      Whispers.error("학번을 선택해 주세요", self.navigationController)
      return
    }
    
    guard let teachers = values["teachers"] as? Set<Teacher> else {
      Whispers.error("선생님을 선택해 주세요", self.navigationController)
      return
    }
    
    let agreeAll = values["agreeAll"] as? Bool ?? false
    let tos = values["tos"] as? Bool ?? false
    let privacy = values["privacy"] as? Bool ?? false
    
    if !(agreeAll || tos && privacy)  {
      Whispers.error("약관 동의를 해주세요", self.navigationController)
      return
    }
    
    let teacherIds = teachers.map { $0.id }
    
    // do signup
    navigationItem.rightBarButtonItem?.enabled = false
    let form: [String: AnyObject] = [
      "email": email,
      "password": password,
      "device": currentDevice,
      "name": name,
      "gender": gender,
      "studentId": studentId.description,
      "teachers": teacherIds,
      "serial": serial.serial,
      "rpassword": passwordConfirm,
    ]
    API.instance.signup(form)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] response in
        if let authUser = response.data where response.status == 200 {
          self?.log.debug("response=\(response)")
          let schoolId = self?.serial.schoolId
          let loggedInUser: [String: AnyObject] = [
            "id": authUser.id,
            "grade": authUser.grade,
            "role": authUser.role,
            "email": email,
            "name": name,
            "gender": gender,
            "schoolId": schoolId!
          ]
          Defaults[.userId] = authUser.id
          Defaults[.token] = authUser.token
          Defaults[.role] = authUser.role
          Defaults[.grade] = authUser.grade
          Defaults[.user] = loggedInUser
          SessionManager.instance.token = authUser.token
          SessionManager.instance.user = loggedInUser
          SessionManager.instance.userId = authUser.id
          dispatch_async(dispatch_get_main_queue()) {
            DefaultWireframe.switchRootViewController(UINavigationController(rootViewController: LauncherViewController()), animated: true, completion: nil)
          }
          
        }else {
          HUD.error()
          if let message = response.message {
            Whispers.error(message, self?.navigationController)
          } else {
            Whispers.error("가입에 실패하였습니다. 잠시 후 다시 시도해 주세요.", self?.navigationController)
          }
        }
        
        }, onError: { [weak self] error in
          HUD.error()
          self?.navigationItem.rightBarButtonItem?.enabled = true
          if let apiError = error as? APIError {
            switch apiError {
            case .BadRequest(let message) :
              switch message! {
              case "email.invalid":
                Whispers.error("잘못된 이메일입니다.", self?.navigationController)
              case "email.taken":
                Whispers.error("사용하고 있는 이메일입니다. 다른 이메일을 입력해 주세요.", self?.navigationController)
              default:
                Whispers.error(message!, self?.navigationController)
                break
              }
              return
            default: break
            }
          }
          
          Whispers.error("가입에 실패하였습니다. 잠시 후 다시 시도해 주세요.", self?.navigationController)
          
        }).addDisposableTo(disposeBag)
    
    
  }
}
