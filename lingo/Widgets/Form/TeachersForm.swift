//
//  TeachersForm.swift
//  lingo
//
//  Created by Taehyun Park on 2/11/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import SnapKit



public final class MultipleTeacherSelectorRow : _MultipleSelectorRow<Teacher, PushSelectorCell<Set<Teacher>>>, RowType {
  public required init(tag: String?) {
    super.init(tag: tag)
    self.displayValueFor = {
      if let t = $0 {
        return "\(t.map({ $0.name }).joinWithSeparator(", ")) 선생님"
      }
      return nil
    }
  }
}