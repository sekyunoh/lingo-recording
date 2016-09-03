//
//  MultipleChoiceQuestionViewController.swift
//  lingo
//
//  Created by Taehyun Park on 3/7/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif
import RealmSwift


class MultipleChoiceQuestionViewController: BaseQuestionViewController {
  
  var choiceButtons: [ChoiceButton]!
  
  
  var userInput: ChoiceButton?
  
  override func loadView() {
    super.loadView()
    
    let choicesHolder = UIView()
    view.addSubview(choicesHolder)
    choicesHolder.snp_makeConstraints {
      $0.width.equalTo(view)
      $0.left.right.equalTo(view)
      $0.bottom.equalTo(view).offset(-20)
      $0.top.equalTo(upperCardView.snp_bottom).offset(8)
    }
    
    choiceButtons = [ChoiceButton]()
    for _ in 1...4  {
      choiceButtons.append(ChoiceButton())
    }
    var upperView: UIView?
    for choiceButton in choiceButtons {
      choicesHolder.addSubview(choiceButton)
      choiceButton.snp_makeConstraints {
        $0.left.right.equalTo(choicesHolder)
        $0.width.equalTo(choicesHolder)
        if choiceButton == choiceButtons.last {
          $0.height.equalTo(choicesHolder).dividedBy(4)
        } else {
          $0.height.equalTo(choicesHolder).dividedBy(4).offset(-1)
        }
        if let upperView = upperView {
          $0.top.equalTo(upperView.snp_bottom)
        } else {
          $0.top.equalTo(choicesHolder)
        }
      }
      if choiceButton == choiceButtons.last {
        break
      }
      let divider = UIView().then {
        $0.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
      }
      choicesHolder.addSubview(divider)
      divider.snp_makeConstraints {
        $0.left.right.equalTo(choicesHolder)
        $0.width.equalTo(choicesHolder)
        $0.height.equalTo(1)
        $0.top.equalTo(choiceButton.snp_bottom)
      }
      upperView = divider
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  
  func didTapChoice(choiceButton: ChoiceButton) {
    toggleInputs(false)
    if question.solved == nil {
      userInput = choiceButton
      examViewController.stopTimer()
      displayResult()
    }
  }
  
  // MARK: Question Delegate
  override func setupQuestion() {
    super.setupQuestion()
    let solved = question.solved != nil
    for(choice, choiceButton) in zip(question.choices, choiceButtons) {
      choiceButton.updateChoice(choice)
      if !solved {
        choiceButton.addTarget(self, action: "didTapChoice:", forControlEvents: .TouchUpInside)
      }
    }
  }
  
  override func toggleInputs(enabled: Bool) {
    
    choiceButtons.forEach { $0.userInteractionEnabled = enabled }
  }
  
  override func displayResult() {
    var answerStatus: AnswerStatus
    let solved = question.solved != nil
    if !solved {
      answerStatus = userInput?.choice.choice == question.answer ? AnswerStatus.Correct : AnswerStatus.Incorrect
      try! realm.write {
        question.input = userInput?.choice.choice
        question.solved = NSDate()
        question.status = answerStatus.rawValue
      }
      examViewController.updateAnswerStatus(answerStatus)
          userInput?.updateChoiceStatus(answerStatus)
    } else {
      answerStatus = AnswerStatus.ordinal(question.status)
      choiceButtons.forEach { choiceButton in
        if choiceButton.choice.choice == self.question.input {
          choiceButton.updateChoiceStatus(answerStatus)
        }
      }
    }
    
    choiceButtons.forEach {
      $0.showAnswerLabel()
      if answerStatus == .Incorrect && $0.choice.choice == self.question.answer {
        $0.updateChoiceStatus(.Correct)
      }
    }
    examViewController.playAudio(question.file, nextQuestionUponFinish: !solved)
  }
}
