//
//  LearningProgressViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/1/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import RealmSwift
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif

class LearningProgressViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
  
  var realm: Realm!
  var publishedGroups: Results<PublishedGroup>!
  
  var reload: Bool = false
  
  var learningProgressView : LearningProgressView {
    return self.view as! LearningProgressView
  }
  
  override func loadView() {
    super.loadView()
    view = LearningProgressView()
    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "didLongTap:")
    longPressGestureRecognizer.minimumPressDuration = 0.5
    learningProgressView.tableView.addGestureRecognizer(longPressGestureRecognizer)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let editionManager = SessionManager.instance.editionManager {
      realm = try! Realm()
      if let published = realm.objectForPrimaryKey(Published.self, key: editionManager.publishedId) {
        publishedGroups = published.groups.sorted("position")
        learningProgressView.tableView.delegate = self
        learningProgressView.tableView.dataSource = self
        return
      }
    }
    dismissViewControllerAnimated(false, completion: nil)
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.title = "학습 현황"
    UINavigationBar.appearance().barTintColor = Theme.learning
    if reload {
      reload = false
      self.learningProgressView.tableView.reloadData()
    }
  }
  
  // MARK: - TableView DataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let groups = publishedGroups {
      return groups.count
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let publishedGroup = publishedGroups?[indexPath.row] {
      let cell = tableView.dequeueReusableCellWithIdentifier(PublishedGroupTableCell.name) as! PublishedGroupTableCell
      
      let learnedGroup = realm.objects(LearnedGroup).filter("groupId == \(publishedGroup.id)").first
      let groupWordIds = publishedGroup.groupWords.map { $0.id }
      let numberOfLearnedWords = realm.objects(LearnedWord).filter("groupWordId IN %@", groupWordIds).count
      cell.bindPublishedGroup(publishedGroup, withLearnedGroup: learnedGroup, withNumberOfLearnedWords: numberOfLearnedWords)
      return cell
    }
    
    return UITableViewCell()
  }
  
  // MARK: - TableView Delegate
  /// Select item at row in tableView.
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("Item selected \(indexPath)")
    // check if the group has been learned
    let publishedGroup = publishedGroups[indexPath.row]
    // check if this has been learned
    let groupWordIds = publishedGroup.groupWords.map { $0.id }
    
    let learnedWordIds = realm.objects(LearnedWord).filter("groupWordId IN %@", groupWordIds).map{ $0.wordId }
    
    if learnedWordIds.count == publishedGroup.numberOfWords {
      //TODO: ask if you want to restudy
      return
    }
    
    learnGroup(publishedGroup, learnedWordIds: learnedWordIds)
  }
  
  func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
    tableView.cellForRowAtIndexPath(indexPath)!.backgroundColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 0.3)
  }
  
  func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
    tableView.cellForRowAtIndexPath(indexPath)!.backgroundColor = UIColor.whiteColor()
  }
  
  func didLongTap(gestureRecognizer: UILongPressGestureRecognizer) {
    let point = gestureRecognizer.locationInView(self.learningProgressView.tableView)
    if let indexPath = self.learningProgressView.tableView.indexPathForRowAtPoint(point) {
      
      let publishedGroup = publishedGroups[indexPath.row]
      // check if this has been learned
      let groupWordIds = publishedGroup.groupWords.map { $0.id }
      let learnedWords = realm.objects(LearnedWord).filter("groupWordId IN %@", groupWordIds)
      let learnedWordIds = learnedWords.map{ $0.wordId }
      
      if learnedWordIds.count > 0 {
        $.wireframe.promptFor(self, title: "배운 단어 삭제", message: "배운 단어를 삭제하시겠습니까?", cancelAction: "취소", actions: ["삭제"])
          .subscribeNext { next in
            if next == "삭제" {
              try! self.realm.write {
                self.realm.delete(learnedWords)
              }
              self.learningProgressView.tableView.reloadData()
            }
        }.addDisposableTo(disposeBag)
        return
      }

      
    }
    
    
  }
  
  func learnGroup(publishedGroup: PublishedGroup, learnedWordIds: [Int]) {
    let publishedId = publishedGroup.publishedId
    let publishedGroupId = publishedGroup.id
    let groupName = publishedGroup.name
    HUD.progress()
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { [weak self] in
      guard let SELF = self else {
        return
      }
      let realm = try! Realm()
      if let publishedGroup = realm.objectForPrimaryKey(PublishedGroup.self, key: publishedGroupId) {
        // if the group consists of
        let keepOrder = publishedGroup.groupWords.reduce(true) {
          return $0 && $1.word.form == idiom
        }
        
        var notLearnedWordIds = publishedGroup.groupWords.map { $0.wordId }
        
        for learnedWordId in learnedWordIds {
          notLearnedWordIds.removeObject(learnedWordId)
        }
        let editionManager = SessionManager.instance.editionManager!
        
        if editionManager.answerManager == nil || editionManager.answerManager?.publishedId != publishedId {
          SELF.log.debug("initialize AnswerManager for publishedId=\(publishedId)")
          editionManager.answerManager = AnswerManager(publishedId: publishedId)
        }
        editionManager.learningManager = LearningManager(groupId: publishedGroupId, name: groupName, keepOrder: keepOrder, notLearnedWordIds: notLearnedWordIds)
        dispatch_async(dispatch_get_main_queue()) {
          SELF.presentViewController(UINavigationController(rootViewController: LearningStep1ViewController()), animated: true) {
            SELF.reload = true
            HUD.hide()
          }
        }
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          HUD.error()
        }
      }
    }
  }
  
}
