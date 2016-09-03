//
//  EditionManager.swift
//  lingo
//
//  Created by Taehyun Park on 2/15/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import XCGLogger
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif
import RealmSwift
import AVFoundation
import SwiftyUserDefaults

let bufferSize = 1024 * 256 // 256KB

public enum FileError: ErrorType {
  case Unknown
}

public struct Path {
  public static let imagePath = "words/png/"
  public static let soundPath = "words/mp3/"
}

public struct Extension {
  public static let png = ".png"
  public static let mp3 = ".mp3"
}

class EditionManager {
  //  private let imageCache = NSCache()
  //  private let audioCache = NSCache()
  
  var learningManager: LearningManager?
  var answerManager: AnswerManager?
  
  let publishedId: Int!
  let editionId: Int!
  
  let log = XCGLogger.defaultInstance()
  let wordZip: OZZipFile!
  
  let $: Dependencies!
  
  let disposeBag = DisposeBag()
  
  let flashcardsSection: DefaultsKey<Int>
  let flashcardsRow: DefaultsKey<Int>
  let quizType: DefaultsKey<Int>
  let questions: DefaultsKey<Int>
  
  init(publishedId: Int, resourceName: String, editionId: Int) {
    //    imageCache.name = "Image " + resourceName
    //    imageCache.countLimit = 30
    //    audioCache.name = "Audio " + resourceName
    //    audioCache.countLimit = 20
    self.publishedId = publishedId
    self.editionId = editionId
    log.debug("loading zip file")
    self.wordZip = try! OZZipFile(fileName: Resources.path(resourceName), mode: OZZipFileMode.Unzip)
    log.debug("zip file loaded")
    $ = Dependencies.instance
    log.debug("editionManager initialized publishedId=\(publishedId) resource=\(resourceName) editionId=\(editionId)")
    flashcardsSection = DefaultsKey<Int>("\(editionId).flashcards.section")
    flashcardsRow = DefaultsKey<Int>("\(editionId).flashcards.row")
    quizType = DefaultsKey<Int>("\(editionId).type")
    questions = DefaultsKey<Int>("\(editionId).questions")
  }
  
  
  
  func image(name: String) -> Driver<UIImage> {
    return Observable.create { [weak self] observer in
      //      self!.log.debug("load image \(name)")
      //      if let image = self!.imageCache.objectForKey(name) as? UIImage {
      //        self!.log.debug("Cache hit name=\(name)")
      //        observer.onNext(image)
      //        observer.onCompleted()
      //      } else {
      do{
        let buffer = NSMutableData(length: bufferSize)!
        let located = try self!.wordZip.locateFileInZip(Path.imagePath + name + Extension.png)
        self!.log.debug("image located=\(located) name=\(name)")
        let stream = try self!.wordZip.readCurrentFileInZip()
        self!.log.debug("read name=\(name) stream=\(stream)")
        let size = try stream.readDataWithBuffer(buffer)
        self!.log.debug("name=\(name) size=\(size)")
        try stream.finishedReading()
        if let image = UIImage(data: buffer) {
          //            self!.log.debug("Store cache name=\(name)")
          //            self!.imageCache.setObject(image, forKey: name, cost: size)
          observer.onNext(image)
        } else {
          observer.onNext(UIImage(named: "loading_error")!)
        }
        observer.onCompleted()
      } catch let error {
        self!.log.error("image name=\(name) load failed")
        observer.onError(error)
      }
      //      }
      return AnonymousDisposable {
        
      }
      }
      .subscribeOn($.zipScheduler)
      .asDriver(onErrorJustReturn: UIImage(named: "loading_error")!)
  }
  
  func audio(name: String) -> Observable<AVAudioPlayer?> {
    return Observable.create { [weak self] observer in
      
      do{
        let buffer = NSMutableData(length: bufferSize)!
        try self!.wordZip.locateFileInZip(Path.soundPath + name + Extension.mp3)
        let stream = try self!.wordZip.readCurrentFileInZip()
        _ = try stream.readDataWithBuffer(buffer)
        try stream.finishedReading()
        let player = try AVAudioPlayer(data: buffer, fileTypeHint: "mp3")
        //        self!.audioCache.setObject(player, forKey: name, cost: size)
        player.prepareToPlay()
        observer.onNext(player)
        observer.onCompleted()
      } catch let error {
        self!.log.error("failed to load name=\(name) error=\(error)")
        observer.onError(error)
      }
      
      
      return AnonymousDisposable {
        
      }
      
      
      
      //      if let player = self!.audioCache.objectForKey(name) as? AVAudioPlayer {
      //        if player.playing {
      //          player.stop()
      //        }
      //        player.prepareToPlay()
      //        observer.onNext(player)
      //        observer.onCompleted()
      //      } else {
      //        do{
      //          let buffer = NSMutableData(length: bufferSize)!
      //          try self!.wordZip.locateFileInZip(Path.soundPath + name + Extension.mp3)
      //          let stream = try self!.wordZip.readCurrentFileInZip()
      //          let size = try stream.readDataWithBuffer(buffer)
      //          try stream.finishedReading()
      //          let player = try AVAudioPlayer(data: buffer, fileTypeHint: "mp3")
      //          self!.audioCache.setObject(player, forKey: name, cost: size)
      //          player.prepareToPlay()
      //          observer.onNext(player)
      //          observer.onCompleted()
      //        } catch let error {
      //          self!.log.error("failed to load name=\(name) error=\(error)")
      //          observer.onError(error)
      //        }
      //      }
      //      return AnonymousDisposable {
      //
      //      }
      }
      .subscribeOn($.zipScheduler)
      .observeOn($.backgroundWorkScheduler)
  }
  
  func wrongLearningWord(groupId: Int, wordId: Int) {
    Dispatcher.worker { [weak self] in
      guard let SELF = self else {
        return
      }
      let realm = try! Realm()
      // check if the word has been wrong
      
      var wrongLearningWord = realm.objects(WrongLearningWord).filter("editionId == \(SELF.editionId) AND wordId == \(wordId)").first
      
      if wrongLearningWord == nil {
        wrongLearningWord = WrongLearningWord(editionId: SELF.editionId, wordId: wordId)
        if let edition = realm.objectForPrimaryKey(Edition.self, key: SELF.editionId) {
          try! realm.write {
            realm.add(wrongLearningWord!)
            edition.wrongLearningWords.append(wrongLearningWord!)
          }
        }
      } else {
        try! realm.write {
          wrongLearningWord!.visible = true
          wrongLearningWord!.count++
        }
      }
      
      let uuid = wrongLearningWord!.uuid
      API.instance.wrongLearningWord(wordId)
        .subscribe(onNext: { response in
          SELF.log.debug("response=\(response)")
          let realm = try! Realm()
          if let learnedWord = realm.objectForPrimaryKey(WrongLearningWord.self, key: uuid) {
            if response.status == 200 {
              try! realm.write {
                learnedWord.sync = SyncStatus.Synchronized.rawValue
              }
            } else {
              try! realm.write {
                learnedWord.sync = SyncStatus.Error.rawValue
              }
            }
          }
          }, onError: { error in
            SELF.log.error("error=\(error)")
            let realm = try! Realm()
            if let learnedWord = realm.objectForPrimaryKey(WrongLearningWord.self, key: uuid) {
              try! realm.write {
                learnedWord.sync = SyncStatus.Error.rawValue
              }
            }
        })
        .addDisposableTo(SELF.disposeBag)
    }
  }
  
  func learnWord(groupId: Int, wordId: Int) {
    Dispatcher.worker { [weak self] in
      guard let SELF = self else {
        return
      }
      let realm = try! Realm()
      // find groupWordId
      guard let groupWordId = realm.objectForPrimaryKey(PublishedGroup.self, key: groupId)?.groupWords
        .filter("wordId == \(wordId)").first
        .map({ $0.id }) else {
          return
      }
      // check if the group word has been learned
      
      var learnedWord = realm.objects(LearnedWord).filter("editionId == \(SELF.editionId) AND groupWordId == \(groupWordId)").first
      
      if learnedWord?.sync == SyncStatus.Synchronized.rawValue {
        return
      }
      
      if learnedWord == nil {
        learnedWord = LearnedWord(editionId: SELF.editionId, groupWordId: groupWordId, wordId: wordId)
        if let edition = realm.objectForPrimaryKey(Edition.self, key: SELF.editionId) {
          try! realm.write {
            realm.add(learnedWord!)
            edition.learnedWords.append(learnedWord!)
          }
        }
      }
      
      let uuid = learnedWord!.uuid
      API.instance.learnWord(groupWordId)
        .subscribe(onNext: { response in
          SELF.log.debug("response=\(response)")
          let realm = try! Realm()
          if let learnedWord = realm.objectForPrimaryKey(LearnedWord.self, key: uuid) {
            if response.status == 200 {
              try! realm.write {
                learnedWord.sync = SyncStatus.Synchronized.rawValue
              }
            } else {
              try! realm.write {
                learnedWord.sync = SyncStatus.Error.rawValue
              }
            }
          }
          }, onError: { error in
            SELF.log.error("error=\(error)")
            let realm = try! Realm()
            if let learnedWord = realm.objectForPrimaryKey(LearnedWord.self, key: uuid) {
              try! realm.write {
                learnedWord.sync = SyncStatus.Error.rawValue
              }
            }
        })
        .addDisposableTo(SELF.disposeBag)
    }
  }
  
  func starWord(wordId: Int) {
    Dispatcher.worker { [weak self] in
      guard let SELF = self else {
        return
      }
      let realm = try! Realm()
      
      var starredWord = realm.objects(StarredWord).filter("editionId == \(SELF.editionId) AND wordId == \(wordId)").first
      
      if starredWord?.sync == SyncStatus.Synchronized.rawValue {
        return
      }
      
      if starredWord == nil {
        starredWord = StarredWord(editionId: SELF.editionId, wordId: wordId)
        if let edition = realm.objectForPrimaryKey(Edition.self, key: SELF.editionId) {
          try! realm.write {
            realm.add(starredWord!)
            edition.starredWords.append(starredWord!)
          }
        }
      }
      
      let uuid = starredWord!.uuid
      API.instance.starWord(wordId)
        .subscribe(onNext: { response in
          SELF.log.debug("response=\(response)")
          let realm = try! Realm()
          if let starredWord = realm.objectForPrimaryKey(StarredWord.self, key: uuid) {
            if response.status == 200 {
              try! realm.write {
                starredWord.sync = SyncStatus.Synchronized.rawValue
              }
            } else {
              try! realm.write {
                starredWord.sync = SyncStatus.Error.rawValue
              }
            }
          }
          }, onError: { error in
            SELF.log.error("error=\(error)")
            let realm = try! Realm()
            if let starredWord = realm.objectForPrimaryKey(StarredWord.self, key: uuid) {
              try! realm.write {
                starredWord.sync = SyncStatus.Error.rawValue
              }
            }
        })
        .addDisposableTo(SELF.disposeBag)
    }
  }
  
  func unstarWord(wordId: Int) {
    Dispatcher.worker { [weak self] in
      guard let SELF = self else {
        return
      }
      let realm = try! Realm()
      
      let starredWord = realm.objects(StarredWord).filter("editionId == \(SELF.editionId) AND wordId == \(wordId)").first
      if starredWord != nil {
        try! realm.write {
          realm.delete(starredWord!)
        }
      }
    
      API.instance.unstarWord(wordId)
        .subscribe(onNext: { response in
          SELF.log.debug("response=\(response)")
          }, onError: { error in
        })
        .addDisposableTo(SELF.disposeBag)
    }
  }
  
  
  func learnGroup(groupId: Int) {
    Dispatcher.worker { [weak self] in
      guard let SELF = self else {
        return
      }
      let realm = try! Realm()
      var learnedGroup = realm.objects(LearnedGroup).filter("editionId == \(SELF.editionId) AND groupId == \(groupId)").first
      if learnedGroup?.sync == SyncStatus.Synchronized.rawValue {
        try! realm.write {
          learnedGroup!.learnedCount = learnedGroup!.learnedCount + 1
        }
        return
      }
      
      let publishedGroup = realm.objectForPrimaryKey(PublishedGroup.self, key: groupId)!
      
      if learnedGroup == nil {
        learnedGroup = LearnedGroup(publishedId: SELF.publishedId, editionId: SELF.editionId, groupId: groupId, name: publishedGroup.name, position: publishedGroup.position, numberOfWords: publishedGroup.numberOfWords)
        if let edition = realm.objectForPrimaryKey(Edition.self, key: SELF.editionId) {
          try! realm.write {
            realm.add(learnedGroup!)
            edition.learnedGroups.append(learnedGroup!)
          }
        }
      }
      
      API.instance.learnGroup(groupId)
        .subscribe(onNext: { response -> Void in
          let realm = try! Realm()
          if let learnedGroup = realm.objectForPrimaryKey(LearnedGroup.self, key: groupId) {
            if response.status == 200 {
              try! realm.write {
                learnedGroup.sync = SyncStatus.Synchronized.rawValue
              }
            } else {
              try! realm.write {
                learnedGroup.sync = SyncStatus.Error.rawValue
              }
            }
          }
          }, onError: {  error  in
            SELF.log.error("error=\(error)")
            let realm = try! Realm()
            if let learnedGroup = realm.objectForPrimaryKey(LearnedGroup.self, key: groupId) {
              try! realm.write {
                learnedGroup.sync = SyncStatus.Error.rawValue
              }
            }
        }).addDisposableTo(SELF.disposeBag)
      
    }
  }
  
  
  private func clearCache() {
    //    imageCache.removeAllObjects()
    //    audioCache.removeAllObjects()
  }
  
  deinit {
    log.debug("deinit")
    try! self.wordZip.close()
    clearCache()
  }
}