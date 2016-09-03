//
//  AnswerManager.swift
//  lingo
//
//  Created by Taehyun Park on 2/27/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import RealmSwift

let numberOfChoices = 4

protocol Choiceable {
  var choice: String { get }
  var explanation: String { get }
}

struct Choice : Equatable {
  let id: Int
  let word: String
  let form: String
  let definition: String
  let filename: String
  var example: String?
  var highlight: String?
  
  init(_ word: Word) {
    self.id = word.id
    self.word = word.word
    self.form = word.form
    self.definition = word.krDefinition
    self.filename = word.filename
    self.example = word.example
    self.highlight = word.highlight
  }
  
  func toChoiceable(type: QuestionAnswerType) -> Choiceable {
    switch type {
    case .DefinitionToWord:
      return ChoicePair(choice: word, explanation: definition)
    default:
      return ChoicePair(choice: definition, explanation: word)
    }
  }
}

func ==(lhs: Choice, rhs: Choice) -> Bool {
  return lhs.id == rhs.id
}

class AnswerManager {
  let publishedId: Int
  let choices: [Choice]
  init(publishedId: Int) {
    self.publishedId = publishedId
    let realm = try! Realm()
    let published = realm.objectForPrimaryKey(Published.self, key: publishedId)!
    choices = published.words.map { Choice($0) }
  }
  
  func generateAnswer(word: Word) -> [Choice] {
    var choices = [Choice]()
    var addedWord = Set<String>()
    
    for _ in 1...numberOfChoices - 1 {
      var choice: Choice!
      repeat {
        choice = self.choices[Int(arc4random_uniform(UInt32(self.choices.count)))]
      } while choice==nil || choice.word == word.word || addedWord.contains(choice.word)
      choices.append(choice)
      addedWord.insert(choice.word)
    }
    choices.append(Choice(word))
    return choices.shuffle()
  }
  
  static func getAnswerCandidates(answer: String) -> Set<String> {
    var answers = Set<String>()
    if answer.containsString(",") {
      for word in answer.componentsSeparatedByString(",") {
        answers.insert(word.replacePunctuationCharacters().trim().lowercaseString)
      }
    } else {
      answers.insert(answer.replacePunctuationCharacters().trim().lowercaseString)
    }
    answers.insert(answer.trim().lowercaseString)
    return answers
  }
  
  static func checkAnswer(input: String?, answerCandidates: Set<String>) -> AnswerStatus {
    if let input = input {
      return answerCandidates.contains(input.trim().lowercaseString) ? AnswerStatus.Correct : AnswerStatus.Incorrect
    }
    
    return AnswerStatus.Incorrect
  }
}