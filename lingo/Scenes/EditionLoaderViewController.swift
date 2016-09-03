//
//  EditionLoaderViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/7/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import RealmSwift
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif


class EditionLoaderViewController: ViewController {
  var dismissViewControllerBlock: (() -> ())!
  
  let published: Published
  var realm: Realm!
  
  var message = Variable<String>("")
  
  var launcherView: EditionLoaderView {
    return self.view as! EditionLoaderView
  }
  
  
  init(_ published: Published) {
    self.published = published
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    view = EditionLoaderView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    realm = try! Realm()
    let view = self.view as! EditionLoaderView
    view.quitButton.rx_tap.asDriver().driveNext(dismiss).addDisposableTo(disposeBag)
    view.retryButton.rx_tap.asDriver().driveNext(downloadWordFile).addDisposableTo(disposeBag)
    message.asDriver().drive(view.messageLabel.rx_text).addDisposableTo(disposeBag)
    self.log.debug("resourceExists=\(Resources.exists(published.resourceName))")
    if let publishedStatus = realm.objects(PublishedStatus).filter("id == \(published.id)").first {
      if publishedStatus.checksum != published.checksum {
        downloadWordFile()
      } else if publishedStatus.version != published.version {
        persistWords(publishedStatus)
      } else {
        synchronizeEdition()
      }
    } else {
      downloadWordFile()
    }
    
    //    dismissViewControllerAnimated(false, completion: { [weak self] in
    //      self?.log.debug("dismissedViewController")
    //      //      self?.dismissViewControllerBlock()
    //      })
    //    dismissViewControllerAnimated(true, completion: dismissViewControllerBlock)
  }
  
  private func dismiss() {
    log.debug("dismiss")
    self.dismissViewControllerAnimated(false) {
      self.dismissViewControllerBlock?()
    }
  }
  
  private func downloadWordFile() {
    message.value = "파일을 다운로드중입니다."
    let view = self.view as! EditionLoaderView
    let totalSize = published.resourceSize
    view.loading()
    API.instance.downloadWordResource(published.id, resourceName: published.resourceName, progress: { [weak self] (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
      guard let SELF = self else {
        return
      }
      dispatch_async(dispatch_get_main_queue()) {
        view.progress.progress = Float(totalBytesRead) / Float(totalSize)
      }
      SELF.log.debug("bytesRead=\(bytesRead) totalBytesRead=\(totalBytesRead) totalBytesExpectedToRead=\(totalBytesExpectedToRead)")
      }){ [weak self] (_, _, _, error) in
        guard let SELF = self else {
          return
        }
        if let error = error {
          SELF.message.value = error.localizedDescription
          SELF.log.error("Failed to download: \(error)")
          view.error()
        } else {
          SELF.message.value = "다운로드가 완료되었습니다."
          view.progress.hidden = true
          SELF.validateFile()
          SELF.log.debug("Downaloded file successfully")
          
        }
    }
  }
  
  private func validateFile() {
    message.value = "유효성 검사중입니다."
    let publishedId = published.id
    if published.resourceSize == Resources.size(published.resourceName) {
      if let publishedStatus = realm.objectForPrimaryKey(PublishedStatus.self, key: publishedId) {
        try! realm.write {
          publishedStatus.status = PublishedStatus.downloaded
          publishedStatus.checksum = published.checksum
        }
        persistWords(publishedStatus)
      } else {
        try! realm.write {
          let publishedStatus = PublishedStatus()
          publishedStatus.id = publishedId
          publishedStatus.status = PublishedStatus.downloaded
          publishedStatus.checksum = published.checksum
          realm.add(publishedStatus)
          persistWords(publishedStatus)
        }
      }
    } else{
      message.value = "다운로드된 파일이 다릅니다."
      launcherView.error()
    }
  }
  
  private func persistWords(publishedStatus: PublishedStatus) {
    message.value = "단어 목록을 갱신중입니다."
    if published.groups.count == 0 || publishedStatus.version != published.version {
      let publishedId = published.id
      API.instance.getWords(publishedId)
        .observeOn($.backgroundWorkScheduler)
        .subscribe(onNext: { [weak self] response in
          guard let SELF = self else {
            return
          }
          if let publishedGroups = response.data {
            let realm = try! Realm()
            try! realm.write {
              realm.add(publishedGroups, update: true)
              if let published = realm.objectForPrimaryKey(Published.self, key: publishedId), let publishedStatus = realm.objectForPrimaryKey(PublishedStatus.self, key: publishedId) {
                if !published.groups.isEmpty {
                  published.groups.removeAll()
                }
                
                if !published.words.isEmpty {
                  published.words.removeAll()
                }
                published.groups.appendContentsOf(publishedGroups)
                
                for publishedGroup in publishedGroups {
                  for groupWord in publishedGroup.groupWords {
                    published.words.append(groupWord.word)
                  }
                }
                
                publishedStatus.status = PublishedStatus.wordsLoaded
                publishedStatus.version = published.version
                SELF.log.debug("update publisehdStatus status=\(publishedStatus.status) version=\(publishedStatus.version)")
                dispatch_async(dispatch_get_main_queue()) {
                  SELF.synchronizeEdition()
                }
              }
              
            }
            
          }
          }, onError: { [weak self] error in
            guard let SELF = self else {
              return
            }
            SELF.log.error("error=\(error)")
            
          }).addDisposableTo(disposeBag)
    }
  }
  
  
  private func synchronizeEdition() {
    message.value = "에디션을 동기화중입니다."
    let publishedId = published.id
    let resourceName = published.resourceName
    API.instance.getEdition(publishedId)
      .observeOn($.backgroundWorkScheduler)
      .subscribe(onNext: { [weak self] response in
        guard let SELF = self else {
          return
        }
        SELF.log.debug("response=\(response)")
        if let edition = response.data {
          let realm = try! Realm()
          if let realmEdition = realm.objects(Edition).filter("publishedId=\(publishedId)").first {
            
            
          } else{
            for learnedWord in edition.learnedWords {
              learnedWord.sync = SyncStatus.Synchronized.rawValue
            }
            
            for starredWord in edition.starredWords {
              starredWord.sync = SyncStatus.Synchronized.rawValue
            }
            
            for learnedGroup in edition.learnedGroups {
              learnedGroup.sync = SyncStatus.Synchronized.rawValue
            }
            try! realm.write {
              realm.add(edition)
            }
          }
          SessionManager.instance.editionManager = EditionManager(publishedId: publishedId, resourceName: resourceName, editionId: edition.id)
          dispatch_async(dispatch_get_main_queue()) {
            SELF.dismiss()
          }
          
        } else {
          
        }
        }, onError:{ [weak self] error in
          guard let SELF = self else {
            return
          }
          SELF.log.error("error=\(error)")
          
        }).addDisposableTo(disposeBag)
  }
}
