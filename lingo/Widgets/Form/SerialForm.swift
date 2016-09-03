//
//  SerialForm.swift
//  lingo
//
//  Created by Taehyun Park on 2/11/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import UIKit
import Eureka


public class SerialCell : _FieldCell<String>, CellType {
  
  required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  public override func setup() {
    super.setup()
    textField.autocorrectionType = .No
    textField.autocapitalizationType = .AllCharacters
    textField.keyboardType = .ASCIICapable
    textField.clearButtonMode = .WhileEditing
  }
}

public class _SerialRow: FieldRow<String, SerialCell> {
  public required init(tag: String?) {
    super.init(tag: tag)
  }
}


public final class SerialRow: _SerialRow, RowType {
  required public init(tag: String?) {
    super.init(tag: tag)
    onCellHighlight { cell, row  in
      let color = cell.textLabel?.textColor
      row.onCellUnHighlight { cell, _ in
        cell.textLabel?.textColor = color
      }
      cell.textLabel?.textColor = cell.tintColor
    }
  }
}
