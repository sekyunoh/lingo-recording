//
//  LoginViewModel.swift
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

class LoginViewModel {
  
  
  let validatedEmail: Driver<ValidationResult>
  let validatedPassword: Driver<ValidationResult>
  
  
  init(input: (
    email: Driver<String>,
    password: Driver<String>,
    loginTaps: Driver<Void>
    ), dependency: (
    API: API,
    validationService: ValidationService
    )) {
      let API = dependency.API
      let validationService = dependency.validationService
      
      validatedEmail = input.email.map { email in
        return validationService.validateEmail(email)
      }
      
      validatedPassword = input.password.map { password in
        return validationService.validatePassword(password)
      }
      
      
  }
  
  
}