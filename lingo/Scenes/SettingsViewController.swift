//
//  SettingsViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/1/16.
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
import MessageUI


class SettingsViewController: BaseFormViewController, MFMailComposeViewControllerDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupForm()
    // Do any additional setup after loading the view.
  }
  
  private func setupForm() {
    form
      +++ Section("플래시 카드")
      <<< SwitchRow("autoPlay") {
        $0.title = "자동 재생"
        $0.value = Defaults[.autoPlay]
        }.onChange {
          Defaults[.autoPlay] = $0.value!
      }
      <<< SegmentedRow<Int>("repeat") {
        $0.title = "반복 횟수"
        $0.options = [0, 1, 2, 3]
        $0.value = Defaults[.repeatCount]
        $0.disabled = Condition.Function(["autoPlay"], { (form) -> Bool in
          let row: SwitchRow! = form.rowByTag("autoPlay")
          let value = row.value ?? false
          return !value
        })
        }.onChange {
          Defaults[.repeatCount] = $0.value!
      }
      
      <<< SegmentedRow<Int>("delay") {
        $0.title = "발음 재생 후 딜레이"
        $0.options = [0, 1, 2, 3]
        $0.value = Defaults[.delay]
        $0.disabled = Condition.Function(["autoPlay"], { (form) -> Bool in
          let row: SwitchRow! = form.rowByTag("autoPlay")
          let value = row.value ?? false
          return !value
        })
        }.onChange {
          Defaults[.delay] = $0.value!
      }
      
      +++ Section("이미지 보카 정보")
      <<< LabelRow() {
        $0.title = "버전"
        $0.value = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as? String
      }
      <<< LabelRow() {
        $0.title = "피드백 보내기"
        }.onCellSelection { _,_ in
          self.sendMail()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.title = "설정"
  }
  
  func sendMail() {
    let picker = MFMailComposeViewController()
    picker.mailComposeDelegate = self
    picker.setToRecipients(["이미지 보카 고객지원 <support@techsavvym.com>"])
    let sdkVersion = "\(NSProcessInfo().operatingSystemVersion.majorVersion).\(NSProcessInfo().operatingSystemVersion.minorVersion).\(NSProcessInfo().operatingSystemVersion.patchVersion)"
    picker.setMessageBody("\n\n모델명: \(DeviceKit.Device().description)\nOS: iOS \(sdkVersion)\n어플:\(App.version)", isHTML: false)
    presentViewController(picker, animated: true, completion: nil)
  }
  
  
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
