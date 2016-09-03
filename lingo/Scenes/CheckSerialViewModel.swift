//
//  CheckSerialViewModel.swift
//  lingo
//
//  Created by Taehyun Park on 2/3/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif


class CheckSerialViewModel {
  let serialValidated: Driver<Bool>
  let serial: Driver<Serial?>
  
  init(
    input: (
    serial: Driver<String>,
    authTaps: Driver<Void>
    ), api: API) {
      serialValidated = input.serial
        .throttle(0.3)
        .distinctUntilChanged()
        .map { $0.length > 5 }
      serial = input.authTaps
        .withLatestFrom(input.serial)
        .flatMapLatest {
          return api.validateSerial($0).asDriver(onErrorJustReturn: nil)
      }
      
  }
  
}