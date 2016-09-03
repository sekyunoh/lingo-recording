//
//  QuizFormViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/22/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
import XLPagerTabStrip
import Eureka
import SwiftyUserDefaults
import RealmSwift

class QuizFormViewController: BaseFormViewController, IndicatorInfoProvider {
  
  var itemInfo = IndicatorInfo(title: "오프라인 모의 시험")
  var realm: Realm!
  var publishedGroups: Results<PublishedGroup>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView?.snp_makeConstraints {
      $0.width.equalTo(view)
      $0.top.equalTo(view)
      $0.bottom.equalTo(view).offset(-globalTabbarHeight)
    }
    
    if let editionManager = SessionManager.instance.editionManager {
      realm = try! Realm()
      if let published = realm.objectForPrimaryKey(Published.self, key: editionManager.publishedId) {
        setupForm(published)
      }
      
      
    }
  }
  
  private func setupForm(published: Published) {
    form +++
      Section()
      <<< LabelRow() {
        $0.title = "에디션"
        $0.value = published.name
      }
      +++
      Section("시험 설정")
      <<< AlertRow<QuestionType>("type") {
        $0.title = "시험 유형"
        $0.options = QuestionType.values
        $0.value = $0.options[0]
        $0.selectorTitle = "시험 유형을 선택해 주세요."
      }
      //      <<< PickerInlineRow<QuestionImage>("image") { (row : PickerInlineRow<QuestionImage>) -> Void in
      //        row.title = "그림 표시"
      //        row.displayValueFor = {
      //          guard let value = $0 else{
      //            return nil
      //          }
      //          return value.description
      //        }
      //        row.options = QuestionImage.values
      //        row.value = row.options[0]
      //      }
      //      <<< PickerInlineRow<QuestionAnswerType>("type") { (row : PickerInlineRow<QuestionAnswerType>) -> Void in
      //        row.title = "문제 형식"
      //        row.displayValueFor = {
      //          guard let value = $0 else{
      //            return nil
      //          }
      //          return value.description
      //        }
      //
      //        row.options = QuestionAnswerType.values
      //        row.value = row.options[0]
      //      }
      //      <<< PickerInlineRow<QuestionForm>("form") { (row : PickerInlineRow<QuestionForm>) -> Void in
      //        row.title = "정답 선택"
      //        row.displayValueFor = {
      //          guard let value = $0 else{
      //            return nil
      //          }
      //          return value.description
      //        }
      //
      //        row.options = QuestionForm.values
      //        row.value = row.options[0]
      //        }
      //
      //      +++ Section("세부 설정")
      <<< SegmentedRow<Int>("questions") { (row: SegmentedRow<Int>) -> Void in
        row.title = "문항 개수"
        row.options = [10, 20, 30, 40, 50]
        row.value = 20
      }
      <<< QuizRangePickerInlineRow("range") { (row : QuizRangePickerInlineRow) -> Void in
        row.title = "시험 범위"
        row.groups = published.groups.sorted("position")
        row.displayValueFor = {
          guard let value = $0 else{
            return "시험 범위를 설정해주세요."
          }
          if value.start == value.end {
            return row.groups[value.start].name
          }
          return "\(row.groups[value.start].name) ~ \(row.groups[value.end].name)"
        }
        }.cellSetup { cell, row in
          cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
          cell.detailTextLabel?.minimumScaleFactor = 0.5
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "시험 출제", style: .Plain, target: self, action: "didTapStartQuiz:")
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.navigationItem.rightBarButtonItem = nil
  }
  
  func didTapStartQuiz(sender: UIBarButtonItem) {
    let values = form.values()
    
    guard let type = values["type"] as? QuestionType else {
      Whispers.error("시험 유형을 선택해 주세요.", self.navigationController)
      return
    }
    
    guard let numberOfQuestions = values["questions"] as? Int else {
      Whispers.error("문제 개수를 선택해 주세요.", self.navigationController)
      return
    }
    
    guard let range = values["range"] as? QuizRange else {
      Whispers.error("시험 범위를 선택해 주세요.", self.navigationController)
      return
    }
    
    HUD.progress()
    Dispatcher.worker {
      let realm = try! Realm()
      guard let userId = SessionManager.instance.userId, let publishedId = SessionManager.instance.editionManager?.publishedId, let editionId = SessionManager.instance.editionManager?.editionId else {
        Dispatcher.main {
          HUD.error()
        }
        return
      }
      
      guard let published = realm.objectForPrimaryKey(Published.self, key: publishedId) else {
        Dispatcher.main {
          HUD.error()
        }
        return
      }
      let publishedGroups = published.groups.sorted("position")
      var words = Set<Word>()
      for index in range.start...range.end {
        publishedGroups[index].groupWords.forEach {
          words.insert($0.word)
        }
      }
      
      var candidates = Array(words)

      let overflow = candidates.count - numberOfQuestions
      
      if overflow > 0 {
        for _ in 0..<overflow {
          candidates.removeAtIndex(Int(arc4random_uniform(UInt32(candidates.count))))
        }
      }
      
      candidates.shuffleInPlace()
      
      let name: String = {
        if range.start == range.end {
          return "\(publishedGroups[range.start].name) 모의 시험"
        }
        return "\(publishedGroups[range.start].name) ~ \(publishedGroups[range.end].name) 모의 시험"
      }()
      
      let answerManager: AnswerManager? = type.isMultipleChoice ? AnswerManager(publishedId: publishedId) : nil
      let quiz = Quiz(authorId: userId, publishedId: publishedId, editionId: editionId, name: name)
      for index in 0..<candidates.count {
        let word = candidates[index]
        let question = type.toQuestion(quiz, answerManager: answerManager, number: index, word: word)
        quiz.questions.append(question)
      }
      
      try! realm.write {
        realm.add(quiz, update: true)
      }
      self.log.debug("quiz=\(quiz)")
      let quizId = quiz.id
      let numberOfQuestions = quiz.questions.count
      Dispatcher.main {
        self.presentViewController(UINavigationController(rootViewController: ExamViewController(quizId: quizId, numberOfQuestions: numberOfQuestions)), animated: true, completion: nil)
      }
    }
  }
  
  func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return itemInfo
  }
}
