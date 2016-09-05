//
//  StudentIdForm.swift
//  lingo
//
//  Created by Taehyun Park on 2/9/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import SnapKit

public class StudentId: Equatable, CustomStringConvertible {
  var grade: Int!
  var clazz: Int!
  var number: Int!
  var raw: String?
  
  convenience init() {
    self.init(grade: 1, clazz: 1, number: 1)
  }
  
  init(studentId: String) {
    if let parsed = Int(studentId) {
      grade = parsed / 10000
      clazz = (parsed % 10000) / 100
      number = parsed % 100
    } else {
      raw = studentId
    }
  }
  
  init(grade: Int, clazz: Int, number: Int) {
    self.grade = grade
    self.clazz = clazz
    self.number = number
  }
  
  
  public var description: String {
    return raw ?? String(format: "%01d%02d%02d", arguments: [grade, clazz, number])
  }
}

public func ==(lhs: StudentId, rhs: StudentId) -> Bool {
  return lhs.grade == rhs.grade && lhs.clazz == rhs.clazz && lhs.number == rhs.number
}

public class StudentIdInlineCell : Cell<StudentId>, CellType {
  
  public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    height = { 44.0 }
  }
  
  public override func setup() {
    super.setup()
    accessoryType = .None
    editingAccessoryType =  .None
  }
  
  public override func update() {
    super.update()
    selectionStyle = row.isDisabled ? .None : .Default
    detailTextLabel?.text = row.displayValueFor?(row.value)
  }
  
  public override func didSelect() {
    super.didSelect()
    row.deselect()
  }
}


public class StudentIdPickerCell : Cell<StudentId>, CellType, UIPickerViewDataSource, UIPickerViewDelegate {
  private var pickerRow : _StudentIdPickerRow? { return row as? _StudentIdPickerRow }
  
  public lazy var picker: UIPickerView = { [unowned self] in
    let picker = UIPickerView()
    picker.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(picker)
    self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[picker]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": picker]))
    self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[picker]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": picker]))
    let screenWidth = self.contentView.bounds.width
    let width = screenWidth / 3.0
    let gradeLabel = UILabel().then {
      $0.font = UIFont.boldSystemFontOfSize(20.0)
      $0.text = "학년"
      $0.textAlignment = .Right
    }
    picker.addSubview(gradeLabel)
    gradeLabel.snp_makeConstraints {
      $0.centerY.equalTo(picker)
      $0.right.equalTo(-width*2 - 75)
    }
    let classLabel = UILabel().then {
      $0.font = UIFont.boldSystemFontOfSize(20.0)
      $0.text = "반"
      $0.textAlignment = .Right
    }
    picker.addSubview(classLabel)
    classLabel.snp_makeConstraints {
      $0.centerY.equalTo(picker)
      $0.right.equalTo(-width-45)
    }
    let numberLabel = UILabel().then {
      $0.font = UIFont.boldSystemFontOfSize(20.0)
      $0.text = "번"
      $0.textAlignment = .Right
    }
    picker.addSubview(numberLabel)
    numberLabel.snp_makeConstraints {
      $0.centerY.equalTo(picker)
      $0.right.equalTo(picker).offset(-15)
    }
    return picker
    }()
  
  //  private var pickerRow : _StudentIdPickerRow
  
  public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  public override func setup() {
    super.setup()
    height = { 213 }
    accessoryType = .None
    editingAccessoryType = .None
    picker.delegate = self
    picker.dataSource = self
    
  }
  
  deinit {
    picker.delegate = nil
    picker.dataSource = nil
  }
  
  public override func update() {
    super.update()
    textLabel?.text = nil
    detailTextLabel?.text = nil
    //    selectionStyle = row.isDisabled ? .None : .Default
    //    detailTextLabel?.text = row.displayValueFor?(row.value)
    picker.reloadAllComponents()
    if let v = row.value {
      picker.selectRow(v.grade-1, inComponent: 0, animated: true)
      picker.selectRow(v.clazz-1, inComponent: 1, animated: true)
      picker.selectRow(v.number-1, inComponent: 2, animated: true)
    } else {
      picker.selectRow(picker.numberOfRowsInComponent(0) / 2 - 1, inComponent: 0, animated: true)
      picker.selectRow(0, inComponent: 1, animated: true)
      picker.selectRow(0, inComponent: 2, animated: true)
    }
    
  }
  
  //  public override func didSelect() {
  //    super.didSelect()
  //    row.deselect()
  //  }
  
  //MARK: Data Sources
  public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 3;
  }
  
  public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch component {
    case 0:
      if pickerRow!.elementary! {
        return 6
      } else {
        return 3
      }
    case 1:
      return 20
    default:
      return 99
    }
  }
  //MARK: Delegates
  public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //
    //    if pickerView.selectedRowInComponent(component) == row {
    //      switch component {
    //      case 0:
    //        return "\(row+1)학년"
    //      case 1:
    //        return "\(row+1)반"
    //      default:
    //        return "\(row+1)번"
    //      }
    //    }else{
    //      return "\(row+1)"
    //    }
    return "\(row+1)"
    
  }
  
  public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.row.value = StudentId(grade: pickerView.selectedRowInComponent(0)+1, clazz: pickerView.selectedRowInComponent(1)+1, number: pickerView.selectedRowInComponent(2)+1)
    //    pickerView.reloadComponent(component)
  }
  
}

extension BaseRow {
  
  public func reload(rowAnimation: UITableViewRowAnimation = .None) {
    guard let tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView, indexPath = indexPath() else { return }
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
  }
  
  public func deselect(animated: Bool = true) {
    guard let indexPath = indexPath(), tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView  else {
      return
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: animated)
  }
  
  public func select(animated: Bool = false) {
    guard let indexPath = indexPath(), tableView = baseCell?.formViewController()?.tableView ?? (section?.form?.delegate as? FormViewController)?.tableView  else { return }
    tableView.selectRowAtIndexPath(indexPath, animated: animated, scrollPosition: .None)
  }
}

public protocol _StudentIdPickerRowProtocol {
  var grade : Int? { get set }
  var clazz : Int? { get set }
  var number : Int? { get set }
  var elementary: Bool? { get set }
}

public class _StudentIdInlineRow: Row<StudentId, StudentIdInlineCell>, _StudentIdPickerRowProtocol {
  
  /// The minimum value for this row's UIDatePicker
  public var grade : Int?
  
  /// The maximum value for this row's UIDatePicker
  public var clazz : Int?
  
  /// The interval between options for this row's UIDatePicker
  public var number : Int?
  
  public var elementary: Bool?
  
  required public init(tag: String?) {
    super.init(tag: tag)
    displayValueFor = {
      return $0!.description
    }
  }
}



public class _StudentIdPickerRow : Row<StudentId, StudentIdPickerCell>, _StudentIdPickerRowProtocol {
  
  /// The minimum value for this row's UIDatePicker
  public var grade : Int?
  
  /// The maximum value for this row's UIDatePicker
  public var clazz : Int?
  
  /// The interval between options for this row's UIDatePicker
  public var number : Int?
  
  public var elementary: Bool?
  
  required public init(tag: String?) {
    super.init(tag: tag)
    displayValueFor = nil
  }
  
  public func setupInlineRow(inlineRow: StudentIdPickerRow) {
    inlineRow.grade = grade
    inlineRow.clazz = clazz
    inlineRow.number = number
    inlineRow.elementary = elementary
  }
}

public class _StudentIdPickerInlineRow: Row<StudentId, StudentIdInlineCell>, _StudentIdPickerRowProtocol {
  
  public typealias InlineRow = StudentIdPickerRow
  
  /// The minimum value for this row's UIDatePicker
  public var grade : Int?
  
  /// The maximum value for this row's UIDatePicker
  public var clazz : Int?
  
  /// The interval between options for this row's UIDatePicker
  public var number : Int?
  
  public var elementary: Bool?
  
  public required init(tag: String?) {
    super.init(tag: tag)
    displayValueFor = {
      guard let studentId = $0 else { return nil }
      return studentId.description
    }
  }
  
  public func setupInlineRow(inlineRow: StudentIdPickerRow) {
    inlineRow.grade = grade
    inlineRow.clazz = clazz
    inlineRow.number = number
    inlineRow.elementary = elementary
  }
}

public final class StudentIdPickerRow : _StudentIdPickerRow, RowType {
  public required init(tag: String?) {
    super.init(tag: tag)
  }
}


public typealias StudentIdPickerInlineRow = StudentIdPickerInlineRow_<StudentId>

public final class StudentIdPickerInlineRow_<T>: _StudentIdPickerInlineRow, RowType, InlineRowType {
  
  required public init(tag: String?) {
    super.init(tag: tag)
    onExpandInlineRow { cell, row, _ in
      let color = cell.detailTextLabel?.textColor
      row.onCollapseInlineRow { cell, _, _ in
        cell.detailTextLabel?.textColor = color
      }
      cell.detailTextLabel?.textColor = cell.tintColor
    }
  }
  
  public override func customDidSelect() {
    super.customDidSelect()
    if !isDisabled {
      toggleInlineRow()
    }
  }
}



