//
//  RealmModels.swift
//  lingo
//
//  Created by Taehyun Park on 2/2/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

public protocol Cloneable {
  typealias Object
  func clone() -> Object
}

class Notice: Object {
  dynamic var id = 0
  dynamic var userId = 0
  dynamic var name = ""
  override static func primaryKey() -> String? {
    return "id"
  }
}

class Series: Object, Mappable {
  dynamic var id = 0
  dynamic var name = ""
  dynamic var color = ""
  dynamic var version = 0
  dynamic var schoolId = 0
  dynamic var position = 0
  var publisheds = List<Published>()
  
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    color <- map["color"]
    version <- map["version"]
    schoolId <- map["schoolId"]
    position <- map["position"]
    publisheds <- (map["publisheds"], ListTransform<Published>())
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

class Published: Object, Mappable {
  // the id of a chat is peer's id
  dynamic var id = 0
  dynamic var name = ""
  dynamic var version = 0
  dynamic var inApp = false
  dynamic var resourceName = ""
  dynamic var resourceSize = 0
  dynamic var numberOfGroups = 0
  dynamic var numberOfWords = 0
  dynamic var checksum = ""
  dynamic var seriesId = 0
  dynamic var position = 0
  
  var groups = List<PublishedGroup>()
  var words = List<Word>()
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    version <- map["version"]
    inApp <- map["inApp"]
    resourceName <- map["resourceName"]
    resourceSize <- map["resourceSize"]
    numberOfGroups <- map["numberOfGroups"]
    numberOfWords <- map["numberOfWords"]
    checksum <- map["hash"]
    seriesId <- map["seriesId"]
    position <- map["position"]
    
    groups <- (map["groups"], ListTransform<PublishedGroup>())
    words <- (map["words"], ListTransform<Word>())
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

class PublishedStatus: Object {
  static let none = 0
  static let downloaded = 1
  static let validated = 2
  static let wordsLoaded = 3
  
  // the id of a chat is peer's id
  dynamic var id = 0
  dynamic var status = 0
  dynamic var version = 0
  dynamic var checksum = ""
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

class PublishedGroup: Object, Mappable {
  typealias Object = PublishedGroup
  dynamic var id = 0
  dynamic var publishedId = 0
  dynamic var name = ""
  dynamic var groupDescription = ""
  dynamic var position = 0
  dynamic var numberOfWords = 0
  var groupWords = List<PublishedGroupWord>()
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  
  func mapping(map: Map) {
    id <- map["id"]
    publishedId <- map["publishedId"]
    name <- map["name"]
    groupDescription <- map["description"]
    position <- map["position"]
    numberOfWords <- map["numberOfWords"]
    groupWords <- (map["groupWords"], ListTransform<PublishedGroupWord>())
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

class PublishedGroupWord: Object, Mappable{
  dynamic var id = 0
  dynamic var word: Word!
  dynamic var wordId = 0
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    word <- map["word"]
    wordId <- map["wordId"]
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

class Edition: Object, Mappable {
  // the id of a chat is peer's id
  dynamic var id = 0
  dynamic var name = ""
  dynamic var publishedId = 0
  dynamic var userId = 0
  dynamic var lastLearned = NSDate()
  
  var starredWords = List<StarredWord>()
  var learnedWords = List<LearnedWord>()
  var learnedGroups = List<LearnedGroup>()
  var wrongLearningWords = List<WrongLearningWord>()
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    publishedId <- map["publishedId"]
    userId <- map["userId"]
    lastLearned <- (map["lastLearned"], BetterDateTransform())
    starredWords <- (map["starredWords"], ListTransform<StarredWord>())
    learnedWords <- (map["learnedWords"], ListTransform<LearnedWord>())
    learnedGroups <- (map["learnedGroups"], ListTransform<LearnedGroup>())
    wrongLearningWords <- (map["wrongLearningWords"], ListTransform<WrongLearningWord>())
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

class Word: Object, Mappable, Equatable, Hashable {
  dynamic var id = 0
  dynamic var form = "";
  dynamic var word = "";
  dynamic var pronunciation = "";
  dynamic var synonyms: String? = nil;
  dynamic var antonyms: String? = nil;
  dynamic var krDefinition = "";
  dynamic var filename = "";
  dynamic var example: String? = nil;
  dynamic var exampleKrTranslation: String? = nil;
  dynamic var highlight: String? = nil;
  
  override static func primaryKey() -> String? {
    return "id"
  }
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    form <- map["form"]
    word <- map["word"]
    pronunciation <- map["pronunciation"]
    synonyms <- map["synonyms"]
    antonyms <- map["antonyms"]
    krDefinition <- map["krDefinition"]
    filename <- map["filename"]
    example <- map["example"]
    exampleKrTranslation <- map["exampleKrTranslation"]
    highlight <- map["highlight"]
  }

  override var hashValue: Int {
    return id
  }
}

func ==(lhs: Word, rhs: Word) -> Bool {
  return lhs.id == rhs.id
}

class LearnedWord: Object, Mappable {
  dynamic var uuid = ""
  dynamic var editionId = 0
  dynamic var groupWordId = 0
  dynamic var wordId = 0
  dynamic var created = NSDate()
  dynamic var sync = 0
  
  required convenience init(editionId: Int, groupWordId: Int, wordId: Int) {
    self.init()
    uuid = NSUUID().UUIDString
    self.editionId = editionId
    self.groupWordId = groupWordId
    self.wordId = wordId
    self.sync = SyncStatus.InProgress.rawValue
  }
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    uuid = NSUUID().UUIDString
    editionId <- map["editionId"]
    groupWordId <- map["groupWordId"]
    wordId <- map["wordId"]
    created <- (map["created"], BetterDateTransform())
    sync = SyncStatus.Synchronized.rawValue
  }
  
  
  override static func primaryKey() -> String? {
    return "uuid"
  }
}


class StarredWord: Object, Mappable {
  dynamic var uuid = ""
  dynamic var editionId = 0
  dynamic var wordId = 0
  dynamic var created = NSDate()
  dynamic var sync = 0
  
  required convenience init(editionId: Int, wordId: Int) {
    self.init()
    uuid = NSUUID().UUIDString
    self.editionId = editionId
    self.wordId = wordId
    self.sync = SyncStatus.InProgress.rawValue
  }
  
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    uuid = NSUUID().UUIDString
    editionId <- map["editionId"]
    wordId <- map["wordId"]
    created <- (map["created"], BetterDateTransform())
    sync = SyncStatus.InProgress.rawValue
  }
  
  
  override static func primaryKey() -> String? {
    return "uuid"
  }
}

class WrongLearningWord: Object, Mappable {
  dynamic var uuid = ""
  dynamic var editionId = 0
  dynamic var wordId = 0
  dynamic var created = NSDate()
  dynamic var updated = NSDate()
  dynamic var count = 0
  dynamic var sync = 0
  dynamic var visible = false
  
  required convenience init(editionId: Int, wordId: Int) {
    self.init()
    uuid = NSUUID().UUIDString
    self.editionId = editionId
    self.wordId = wordId
    self.sync = SyncStatus.InProgress.rawValue
    self.visible = true
    self.count = 1
  }
  
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    uuid = NSUUID().UUIDString
    editionId <- map["editionId"]
    wordId <- map["wordId"]
    created <- (map["created"], BetterDateTransform())
    updated <- (map["updated"], BetterDateTransform())
    sync = SyncStatus.InProgress.rawValue
  }
  
  
  override static func primaryKey() -> String? {
    return "uuid"
  }
}

class LearnedGroup: Object, Mappable {
  dynamic var id = 0
  dynamic var created = NSDate()
  dynamic var publishedId = 0
  dynamic var editionId = 0
  dynamic var groupId = 0
  var logs = List<LearnedGroupLog>()
  dynamic var learnedCount = 0
  dynamic var name = ""
  dynamic var position = 0
  dynamic var numberOfWords = 0
  dynamic var uuid = ""
  dynamic var sync = 0
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  
  required convenience init(publishedId: Int, editionId: Int, groupId: Int, name: String, position: Int, numberOfWords: Int) {
    self.init()
    uuid = NSUUID().UUIDString
    self.id = groupId
    self.publishedId = publishedId
    self.editionId = editionId
    self.groupId = groupId
    self.name = name
    self.position = position
    self.numberOfWords = numberOfWords
    self.learnedCount = 1
    self.sync = SyncStatus.InProgress.rawValue
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    created <- (map["created"], BetterDateTransform())
    publishedId <- map["publishedId"]
    editionId <- map["editionId"]
    groupId <- map["groupId"]
    logs <- (map["logs"], ListTransform<LearnedGroupLog>())
    learnedCount <- map["learnedCount"]
    name <- map["name"]
    position <- map["position"]
    numberOfWords <- map["numberOfWords"]
    uuid <- map["uuid"]
    sync = SyncStatus.InProgress.rawValue
  }
  
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

class LearnedGroupLog: Object, Mappable {
  dynamic var groupId = 0
  dynamic var numberOfLearnedWords = 0
  dynamic var created = NSDate()
  dynamic var uuid = ""
  dynamic var sync = 0
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    groupId <- map["groupId"]
    numberOfLearnedWords <- map["numberOfLearnedWords"]
    uuid <- map["uuid"]
    created <- (map["created"], BetterDateTransform())
    sync <- map["sync"]
  }
  
  
  override static func primaryKey() -> String? {
    return "uuid"
  }
}


class Quiz: Object, Mappable {
  // the id of a chat is peer's id
  dynamic var id = 0
  dynamic var quizId = 0
  dynamic var publishedId = 0
  dynamic var editionId = 0
  dynamic var authorId = 0
  dynamic var authorName = ""
  dynamic var statisticsId = 0
  dynamic var startDate = NSDate()
  dynamic var dueDate = NSDate()
  dynamic var score = 0.0
  dynamic var name = ""
  var questions = List<Question>()
  dynamic var retake = 0
  dynamic var penalty = 0
  dynamic var average = 0.0
  dynamic var status = 0
  dynamic var mock = false
  dynamic var sync = 0
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  required convenience init(authorId: Int, publishedId: Int, editionId: Int, name: String) {
    self.init()
    id = -Int((NSDate().timeIntervalSince1970))
    quizId = id
    statisticsId = id
    self.authorId = authorId
    self.publishedId = publishedId
    self.editionId = editionId
    self.name = name
    self.mock = true
    self.sync = SyncStatus.None.rawValue
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    editionId <- map["editionId"]
    quizId <- map["quiz.id"]
    publishedId <- map["quiz.publishedId"]
    authorId <- map["quiz.authorId"]
    authorName <- map["quiz.authorName"]
    statisticsId <- map["quiz.statisticsId"]
    startDate <- (map["quiz.startDate"], BetterDateTransform())
    dueDate <- (map["quiz.dueDate"], BetterDateTransform())
    score <- map["score"]
    name <- map["quiz.name"]
    questions <- (map["quiz.questions"], ListTransform<Question>())
    retake <- map["quiz.retake"]
    penalty <- map["quiz.penalty"]
    average <- map["quiz.average"]
    status <- map["quiz.status"]
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

class Question: Object, Mappable {
  dynamic var id = 0
  dynamic var quizId = 0
  dynamic var wordId = 0
  dynamic var type = ""
  dynamic var number = 0
  dynamic var time = 0
  var choices = List<ChoicePair>()
  dynamic var answer = ""
  dynamic var question = ""
  dynamic var numberOfChoices = 0
  dynamic var file = ""
  dynamic var input: String? = nil
  dynamic var solved: NSDate? = nil
  dynamic var status = 0
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  required convenience init(id: Int, type: String, quizId: Int, number: Int, wordId: Int, answer: String, question: String, file: String, numberOfChoices: Int) {
    self.init()
    self.id = id
    self.type = type
    self.quizId = quizId
    self.number = number
    self.wordId = wordId
    self.answer = answer
    self.question = question
    self.file = file
    self.numberOfChoices = numberOfChoices
    self.time = 60
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    quizId <- map["quizId"]
    wordId <- map["wordId"]
    type <- map["type"]
    number <- map["number"]
    time <- map["time"]
    choices <- (map["choices"], ListTransform<ChoicePair>())
    answer <- map["answer"]
    question <- map["question"]
    numberOfChoices <- map["numberOfChoices"]
    file <- map["file"]
    input <- map["input"]
    solved <- (map["solved"], BetterDateTransform())
    status <- map["status"]
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

class ChoicePair: Object, Mappable, Choiceable {
  dynamic var choice = ""
  dynamic var explanation = ""
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  required convenience init(choice: String, explanation: String){
    self.init()
    self.choice = choice
    self.explanation = explanation
  }
  
  func mapping(map: Map) {
    choice <- map["choice"]
    explanation <- map["explanation"]
  }
  
}

enum QuizStatus: Int {
  case None = 0,
  Solved,
  InProgress
}

enum SyncStatus: Int {
  case None = 0, Synchronized, InProgress, Error
}