//
//  SubjectiveQuestionViewController.swift
//  lingo
//
//  Created by Taehyun Park on 3/7/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit

class SubjectiveQuestionViewController: BaseQuestionViewController, UITextFieldDelegate {
  
  var textField: UITextField!
  
  var userInput: String?
  
  var answerCandidates: Set<String>!
  
  override func loadView() {
    super.loadView()
    textField = UITextField().then {
      $0.textAlignment = .Center
      $0.font = UIFont.systemFontOfSize(18)
      $0.keyboardType = .ASCIICapable
      $0.autocorrectionType = .No
      $0.autocapitalizationType = .None
      $0.returnKeyType = .Done
      $0.clearButtonMode = .WhileEditing
      $0.layer.borderColor = UIColor.lightGrayColor().CGColor
      $0.layer.borderWidth = 1
      $0.layer.cornerRadius = 10
      $0.layer.masksToBounds = true
      $0.placeholder = self.questionType.placeHolder
    }
    view.addSubview(textField)
    textField.snp_makeConstraints {
      $0.top.equalTo(upperCardView.snp_bottom).offset(24)
      $0.left.right.equalTo(upperCardView)
      $0.height.equalTo(32)
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  
  // MARK: Question Delegate
  override func setupQuestion() {
    super.setupQuestion()
    if question.solved == nil {
      answerCandidates = AnswerManager.getAnswerCandidates(question.answer)
      textField.delegate = self
    }
  }
  
  override func toggleInputs(enabled: Bool) {
    textField.enabled = enabled
  }
  
  override func displayResult() {
    var answerStatus: AnswerStatus
    let solved = question.solved != nil
    if !solved {
      answerStatus = AnswerManager.checkAnswer(userInput, answerCandidates: answerCandidates)
      try! realm.write {
        question.input = userInput
        question.solved = NSDate()
        question.status = answerStatus.rawValue
      }
    } else {
      userInput = question.input
      answerStatus = AnswerStatus.ordinal(question.status)
    }
    examViewController.updateAnswerStatus(answerStatus)
    let input = userInput ?? "시간초과"
    textField.text = AnswerStatus.Correct.rawValue == question.status ? question.answer : "입력: \(input) 정답: \(question.answer)"
    examViewController.playAudio(question.file, nextQuestionUponFinish: !solved)
  }
  
  // MARK: TextField Delegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let answer = textField.text where answer.length > 0 {
      toggleInputs(false)
      userInput = answer
      examViewController.stopTimer()
      displayResult()
      return true
    }
    Whispers.error("단어를 입력해 주세요.", self.navigationController)
    return false
  }
}
