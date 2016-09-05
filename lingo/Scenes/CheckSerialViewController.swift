//
//  CheckSerialViewController.swift
//  lingo
//
//  Created by Taehyun Park on 1/4/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import Eureka
import XCGLogger
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif


class CheckSerialViewController: FormViewController {
  
  var appDelegate: AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
  }
  var log: XCGLogger {
    return appDelegate.log
  }
  
  var disposeBag = DisposeBag()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBarHidden = false
    self.title = "제품번호 인증"
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "didClickDone:")
    navigationItem.rightBarButtonItem?.enabled = false
    form
      +++ Section("인증")
      <<< SerialRow("serial") {
        $0.title = "제품번호"
        $0.placeholder = "제품번호를 입력해주세요."
    }.onChange({ row  in
      guard let serial = row.value else {
        return
      }
      self.navigationItem.rightBarButtonItem?.enabled = serial.isValidSerial()
    })
    form.rowByTag("serial")?.highlightCell()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBarHidden = false
  }
  
  func didClickDone(item: UIBarButtonItem) {
    // validate inputs
    let values = form.values()
    
    guard let serial = values["serial"] as? String else {
      Whispers.error("제품번호를 입력해 주세요", self.navigationController)
      return
    }
    
    if !serial.isValidSerial() {
      Whispers.error("올바른 제품번호가 아닙니다", self.navigationController)
      return
    }
    
    API.instance.validateSerial(serial).asDriver(onErrorJustReturn: nil)
      .driveNext { serial in
        guard let serial = serial else {
          Whispers.error("올바른 제품번호가 아닙니다", self.navigationController)
          return
        }
        self.navigationController?.pushViewController(SignupViewController(serial: serial), animated: true)
      }
      .addDisposableTo(disposeBag)
    
    
  }
}

//class CheckSerialViewController: ViewController {
//
//  override func loadView() {
//    super.loadView()
//    view = CheckSerialView(frame: UIScreen.mainScreen().bounds)
//  }
//
//  var viewModel: CheckSerialViewModel!
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    self.navigationController?.navigationBarHidden = false
//    self.title = "제품번호 인증"
//    let view = self.view as! CheckSerialView
//    view.serialTextField.becomeFirstResponder()
//    viewModel = CheckSerialViewModel(input: (view.serialTextField.rx_text.asDriver(), view.checkButton.rx_tap.asDriver()), api: API.instance)
//    viewModel.serialValidated.drive(view.checkButton.rx_enabled).addDisposableTo(disposeBag)
//    viewModel.serial.driveNext { serial in
//      if let serial = serial {
//        self.navigationController?.pushViewController(SignupViewController(serial: serial), animated: true)
//      }else {
//        view.serialTextField.detailLabelHidden = false
//        view.serialTextField.detailLabel?.text = "인증번호가 올바르지 않습니다."
//      }
//      }.addDisposableTo(disposeBag)
//  }
//
//  override func viewWillAppear(animated: Bool) {
//    super.viewWillAppear(animated)
//    self.navigationController?.navigationBarHidden = false
//  }
//
//  private func doSignup() {
//    //    self.navigationController?.pushViewController(SignupViewController(), animated: true)
//  }
//}
