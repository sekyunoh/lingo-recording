//
//  Validations.swift
//  lingo
//
//  Created by Taehyun Park on 1/4/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//


import Foundation

#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif

enum ValidationResult {
  case OK(message: String)
  case Empty
  case Validating
  case Failed(message: String)
}


protocol ValidationService {
  func validateEmail(email: String) -> ValidationResult
  func validatePassword(password: String) -> ValidationResult
  func validateRepeatPassword(password: String, repeatedPassword: String) -> ValidationResult
}

extension ValidationResult {
  var isValid: Bool {
    switch self {
    case .OK:
      return true
    default:
      return false
    }
  }
}



extension String {
  
  func isValidSerial() -> Bool {
    return length >= 6
  }
  
  func isValidEmail() -> Bool {
    do {
      let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .CaseInsensitive)
      return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
    } catch {
      return false
    }
  }
  
  func isValidPassword() -> Bool {
    return length >= 6 && length <= 30
  }
}