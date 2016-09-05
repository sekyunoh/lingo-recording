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
import RealmSwift
import SwiftyJSON

enum QuestionType: String, CustomStringConvertible {
  case Random = "RANDOM"
  case WordToDefMC = "WORD_TO_DEFINITION_MC"
  case WordToDefMCNoImg = "WORD_TO_DEFINITION_MC_WITHOUT_IMAGE"
  case DefToWordMC = "DEFINITION_TO_WORD_MC"
  case DefToWordS = "DEFINITION_TO_WORD_S"
  case DefToWordMCNoImg = "DEFINITION_TO_WORD_MC_WITHOUT_IMAGE"
  case DefToWordSNoImg = "DEFINITION_TO_WORD_S_WITHOUT_IMAGE"
  case ImgToWordMC = "IMAGE_TO_WORD_MC"
  case ImgToWordS = "IMAGE_TO_WORD_S"
  
  var description : String {
    switch self {
    case DefToWordMC :
      return "한글 뜻 제시 → 영단어 선택형"
    case DefToWordS :
      return "한글 뜻 제시 → 영단어 타이핑형"
    case WordToDefMC:
      return "영단어 제시 → 한글 뜻 선택형"
    case DefToWordMCNoImg :
      return "(그림X)한글 뜻 제시 → 영단어 선택형"
    case DefToWordSNoImg :
      return "(그림X)한글 뜻 제시 → 영단어 타이핑형"
    case WordToDefMCNoImg :
      return "(그림X)영단어 제시 → 한글 뜻 선택형"
    case ImgToWordMC :
      return "그림만 제시 → 영단어 선택형"
    case ImgToWordS :
      return "그림만 제시 → 영단어 타이핑형"
    default:
      return "모든 형식 랜덤으로 출제"
    }
  }
  
  static func type(type: String) -> QuestionType {
    switch type {
    case QuestionType.WordToDefMC.rawValue:
      return .WordToDefMC
    case QuestionType.WordToDefMCNoImg.rawValue:
      return .WordToDefMCNoImg
    case QuestionType.DefToWordMC.rawValue:
      return .DefToWordMC
    case QuestionType.DefToWordS.rawValue:
      return .DefToWordS
    case QuestionType.DefToWordMCNoImg.rawValue:
      return .DefToWordMCNoImg
    case QuestionType.DefToWordSNoImg.rawValue:
      return .DefToWordSNoImg
    case QuestionType.ImgToWordMC.rawValue:
      return .ImgToWordMC
    case QuestionType.ImgToWordS.rawValue:
      return .ImgToWordS
    default:
      return .Random
    }
  }
  
  var placeHolder: String? {
    switch self {
    case DefToWordS, DefToWordSNoImg :
      return "뜻을 보고 단어를 입력해 주세요."
    case ImgToWordS :
      return "그림을 보고 단어를 입력해 주세요."
    default:
      return nil
    }
  }
  
  
  static var values: [QuestionType] {
    return [.Random, .WordToDefMC, .WordToDefMCNoImg, .DefToWordMC, .DefToWordS, .DefToWordMCNoImg,
      .DefToWordSNoImg, .ImgToWordMC, .ImgToWordS]
  }
  
  private static var nonRandValues: [QuestionType] {
    return [.WordToDefMC, .WordToDefMCNoImg, .DefToWordMC, .DefToWordS, .DefToWordMCNoImg,
      .DefToWordSNoImg, .ImgToWordMC, .ImgToWordS]
  }
  
  static func random() -> QuestionType {
    return nonRandValues[Int(arc4random_uniform(UInt32(nonRandValues.count)))]
  }
  
  var isMultipleChoice: Bool {
    switch self {
    case Random, WordToDefMC, WordToDefMCNoImg, DefToWordMC, DefToWordMCNoImg, ImgToWordMC:
      return true
    default:
      return false
    }
  }
  
  var displayImage: Bool {
    switch self {
    case WordToDefMCNoImg, DefToWordMCNoImg, DefToWordSNoImg :
      return false
    default:
      return true
    }
  }
  
  var displayQuestion: Bool {
    switch self {
    case .ImgToWordS, .ImgToWordMC:
      return false
    default:
      return true
    }
  }
  
  var validType: QuestionType {
    return self == .Random ? QuestionType.random() : self
  }
  
  var numberOfChoices: Int {
    return isMultipleChoice ? 4 : 0
  }
  
  func toQuestion(quiz: Quiz, answerManager: AnswerManager?, number: Int, word: Word) -> Question {
    
    let pair: (question: String, answer: String) = {
      switch self {
      case .WordToDefMC, .WordToDefMCNoImg:
        return (word.word, word.krDefinition)
      case .ImgToWordMC, .ImgToWordS:
        return (word.filename, word.word)
      default:
        return (word.krDefinition, word.word)
      }
    }()
    let id = -(Int(quiz.startDate.timeIntervalSince1970) + number)
    
    let type = validType
    
    let question = Question(id: id, type: type.rawValue, quizId: quiz.id, number: number, wordId: word.id, answer: pair.answer, question: pair.question, file: word.filename, numberOfChoices: type.numberOfChoices)
    if let answerManager = answerManager where question.numberOfChoices > 0 {
      let choices = answerManager.generateAnswer(word).map { choice -> ChoicePair in
        switch type {
        case .WordToDefMC, .WordToDefMCNoImg:
          return ChoicePair(choice: choice.definition, explanation: choice.word)
        default:
          return ChoicePair(choice: choice.word, explanation: choice.definition)
        }
      }
      choices.forEach(question.choices.append)
    }
    return question
  }
  
  func toViewController(question: Question) -> BaseQuestionViewController {
    return isMultipleChoice ? MultipleChoiceQuestionViewController(question: question) : SubjectiveQuestionViewController(question: question)
  }
}

enum QuestionImage: CustomStringConvertible {
  case Random
  case Image
  case NoImage
  var description : String {
    switch self {
      // Use Internationalization, as appropriate.
    case .Random: return "랜덤"
    case .Image: return "그림 표시"
    case .NoImage: return "그림 숨김"
    }
  }
  static var count: Int {
    return 3
  }
  
  var ordinal: Int {
    switch self {
    case .Random: return 0
    case .Image: return 1
    case .NoImage: return 2
    }
  }
  
  static func ordinal(position: Int) -> QuestionImage {
    switch position {
    case 0:
      return .Random
    case 1:
      return .Image
    default:
      return .NoImage
    }
  }
  
  static var values: [QuestionImage] {
    return [.Random, .Image, .NoImage]
  }
  
  static func random() -> QuestionImage {
    return arc4random_uniform(UInt32(2)) % 2 == 0 ? .Image : .NoImage
  }
}

enum QuestionAnswerType: CustomStringConvertible {
  case Random
  case DefinitionToWord
  case WordToDefinition
  
  var description : String {
    switch self {
    case .Random: return "랜덤"
    case .DefinitionToWord: return "뜻 ➡ 단어"
    case .WordToDefinition: return "단어 ➡ 뜻"
    }
  }
  
  static var count: Int {
    return 3
  }
  
  var ordinal: Int {
    switch self {
    case .Random: return 0
    case .DefinitionToWord: return 1
    case .WordToDefinition: return 2
    }
  }
  
  static func ordinal(position: Int) -> QuestionAnswerType {
    switch position {
    case 0:
      return .Random
    case 1:
      return .DefinitionToWord
    default:
      return .WordToDefinition
    }
  }
  
  static var values: [QuestionAnswerType] {
    return [.Random, .DefinitionToWord, .WordToDefinition]
  }
  
  static func random() -> QuestionAnswerType {
    return arc4random_uniform(UInt32(2)) % 2 == 0 ? .DefinitionToWord : .WordToDefinition
  }
}

enum QuestionForm: CustomStringConvertible {
  case Random
  case MultipleChoice
  case Subjective
  var description : String {
    switch self {
      // Use Internationalization, as appropriate.
    case .Random: return "랜덤"
    case .MultipleChoice: return "객관식(선택)"
    case .Subjective: return "주관식(타이핑)"
    }
  }
  static var count: Int {
    return 3
  }
  
  var ordinal: Int {
    switch self {
    case .Random: return 0
    case .MultipleChoice: return 1
    case .Subjective: return 2
    }
  }
  
  static func ordinal(position: Int) -> QuestionForm {
    switch position {
    case 0:
      return .Random
    case 1:
      return .MultipleChoice
    default:
      return .Subjective
    }
  }
  
  static var values: [QuestionForm] {
    return [.Random, .MultipleChoice, .Subjective]
  }
  
  static func random() -> QuestionForm {
    return arc4random_uniform(UInt32(2)) % 2 == 0 ? .MultipleChoice : .Subjective
  }
}

class QuizRange: Equatable {
  var start: Int!
  var end: Int!
  
  init(start: Int, end: Int){
    self.start = start
    self.end = end
  }
}

func ==(lhs: QuizRange, rhs: QuizRange) -> Bool {
  return lhs.start == rhs.start  && lhs.end == rhs.end
}

class QuizRangeInlineCell : Cell<QuizRange>, CellType {
  
  required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    height = { 44.0 }
  }
  
  override func setup() {
    super.setup()
    accessoryType = .None
    editingAccessoryType =  .None
  }
  
  override func update() {
    super.update()
    selectionStyle = row.isDisabled ? .None : .Default
    detailTextLabel?.text = row.displayValueFor?(row.value)
  }
  
  override func didSelect() {
    super.didSelect()
    row.deselect()
  }
}


class QuizRangePickerCell : Cell<QuizRange>, CellType, UIPickerViewDataSource, UIPickerViewDelegate {
  private var pickerRow : _QuizRangePickerRow? { return row as? _QuizRangePickerRow }
  
  lazy var picker: UIPickerView = { [unowned self] in
    let picker = UIPickerView()
    picker.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(picker)
    self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[picker]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": picker]))
    self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[picker]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": picker]))
    let screenWidth = self.contentView.bounds.width
    let width = screenWidth / 3.0
    //    let gradeLabel = UILabel().then {
    //      $0.font = UIFont.boldSystemFontOfSize(20.0)
    //      $0.text = "학년"
    //      $0.textAlignment = .Right
    //    }
    //    picker.addSubview(gradeLabel)
    //    gradeLabel.snp_makeConstraints {
    //      $0.centerY.equalTo(picker)
    //      $0.right.equalTo(-width*2 - 75)
    //    }
    //    let classLabel = UILabel().then {
    //      $0.font = UIFont.boldSystemFontOfSize(20.0)
    //      $0.text = "반"
    //      $0.textAlignment = .Right
    //    }
    //    picker.addSubview(classLabel)
    //    classLabel.snp_makeConstraints {
    //      $0.centerY.equalTo(picker)
    //      $0.right.equalTo(-width-45)
    //    }
    //    let numberLabel = UILabel().then {
    //      $0.font = UIFont.boldSystemFontOfSize(20.0)
    //      $0.text = "번"
    //      $0.textAlignment = .Right
    //    }
    //    picker.addSubview(numberLabel)
    //    numberLabel.snp_makeConstraints {
    //      $0.centerY.equalTo(picker)
    //      $0.right.equalTo(picker).offset(-15)
    //    }
    return picker
    }()
  
  //  private var pickerRow : _StudentIdPickerRow
  
  required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  override func setup() {
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
  
  override func update() {
    super.update()
    textLabel?.text = nil
    detailTextLabel?.text = nil
    //    selectionStyle = row.isDisabled ? .None : .Default
    //    detailTextLabel?.text = row.displayValueFor?(row.value)
    picker.reloadAllComponents()
    if let v = row.value {
      picker.selectRow(v.start, inComponent: 0, animated: true)
      picker.selectRow(v.end, inComponent: 1, animated: true)
    } else {
      picker.selectRow(0, inComponent: 0, animated: true)
      picker.selectRow(0, inComponent: 1, animated: true)
    }
    
  }
  
  //  override func didSelect() {
  //    super.didSelect()
  //    row.deselect()
  //  }
  
  //MARK: Data Sources
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 2;
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if component == 0 {
      return pickerRow!.groups.count
    } else {
      return pickerRow!.groups.count - pickerView.selectedRowInComponent(0)
    }
  }
  //MARK: Delegates
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if component == 0 {
      return pickerRow!.groups[row].name
    } else {
      return pickerRow!.groups[pickerView.selectedRowInComponent(0)+row].name
    }
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let start = min(pickerView.selectedRowInComponent(0), pickerView.selectedRowInComponent(1))
    let end = max(pickerView.selectedRowInComponent(0), pickerView.selectedRowInComponent(1))
    self.row.value = QuizRange(start: start, end: end)
    if component == 0 {
      pickerView.reloadComponent(1)
    }
  }
  
  func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
    var label = view as? UILabel
    if label == nil {
      label = UILabel().then {
        $0.font = UIFont.systemFontOfSize(14)
        $0.numberOfLines = 0
      }
    }
    label?.text = pickerRow!.groups[row].name
    return label!
  }
  
}

protocol _QuizRangePickerRowProtocol {
  var groups: Results<PublishedGroup>! {get set}
}

class _QuizRangeInlineRow: Row<QuizRange, QuizRangeInlineCell>, _QuizRangePickerRowProtocol {
  var groups: Results<PublishedGroup>!
  
  required init(tag: String?) {
    super.init(tag: tag)
  }
}



class _QuizRangePickerRow : Row<QuizRange, QuizRangePickerCell>, _QuizRangePickerRowProtocol {
  var groups: Results<PublishedGroup>!
  
  
  required init(tag: String?) {
    super.init(tag: tag)
  }
  
  func setupInlineRow(inlineRow: QuizRangePickerRow) {
    inlineRow.groups = groups
  }
}

class _QuizRangePickerInlineRow: Row<QuizRange, QuizRangeInlineCell>, _QuizRangePickerRowProtocol {
  
  typealias InlineRow = QuizRangePickerRow
  
  var groups: Results<PublishedGroup>!
  
  required init(tag: String?) {
    super.init(tag: tag)
  }
  
  func setupInlineRow(inlineRow: QuizRangePickerRow) {
    inlineRow.groups = groups
  }
}

final class QuizRangePickerRow : _QuizRangePickerRow, RowType {
  required init(tag: String?) {
    super.init(tag: tag)
  }
}

typealias QuizRangePickerInlineRow = QuizRangePickerInlineRow_<QuizRange>

final class QuizRangePickerInlineRow_<T> : _QuizRangePickerInlineRow, RowType, InlineRowType{
  
  required init(tag: String?) {
    super.init(tag: tag)
    onExpandInlineRow { cell, row, _ in
      let color = cell.detailTextLabel?.textColor
      row.onCollapseInlineRow { cell, _, _ in
        cell.detailTextLabel?.textColor = color
      }
      cell.detailTextLabel?.textColor = cell.tintColor
    }
  }
  
  override func customDidSelect() {
    super.customDidSelect()
    if !isDisabled {
      toggleInlineRow()
    }
  }
}

extension NSDate {
  var millis: Double {
    return self.timeIntervalSince1970 * 1000
  }
}

extension Quiz {
  func form() -> NSData {
    let userQuestions = questions.map { question -> [String: AnyObject] in
      return ["userInput": question.input ?? "",
        "status" : question.status,
        "questionId": question.id,
        "solved": question.solved!.millis]
    }
    return try! NSJSONSerialization.dataWithJSONObject(["questions": userQuestions], options: [])
  }
  
}

