//
//  Constants.swift
//  lingo
//
//  Created by Taehyun Park on 12/30/15.
//  Copyright © 2015 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import DeviceKit
import AdSupport
#if !RX_NO_MODULE
  import RxSwift
#endif
import UIKit

public struct UI {
  static let extraLargePadding = 32
  static let largePadding = 16
  static let defaultPadding = 8
  static let smallPadding = 4
}

struct Color {
  
}

extension DefaultsKeys {
  static let deviceToken = DefaultsKey<String?>("deviceToken")
  
  static let token = DefaultsKey<String?>("token")
  static let userId = DefaultsKey<Int?>("userId")
  static let grade = DefaultsKey<String>("grade")
  static let role = DefaultsKey<String>("role")
  static let user = DefaultsKey<[String: AnyObject]?>("user")
  
  static let editionId = DefaultsKey<Int>("editionId")
  
  static let autoPlay = DefaultsKey<Bool>("autoPlay")
  static let repeatCount = DefaultsKey<Int>("repeatCount")
  static let delay = DefaultsKey<Int>("delay")
}

let currentDevice: [String: AnyObject] = [
  "name": DeviceKit.Device().description,
  "deviceId": ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString,
  "sdkVersion": NSProcessInfo().operatingSystemVersion.majorVersion*100 + NSProcessInfo().operatingSystemVersion.minorVersion*10 + NSProcessInfo().operatingSystemVersion.patchVersion,
  "appVersion": App.version,
  "os": "IOS",
  "token": Defaults[.deviceToken]!
]

public let idiom = "idm"