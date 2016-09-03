//
//  QuizListViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/22/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SnapKit
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif
import RealmSwift


class QuizListViewController: ViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource {
  
  var itemInfo = IndicatorInfo(title: "온라인 시험")
  
  var tableView: UITableView!
  var refreshControl = UIRefreshControl()
  
  var realm: Realm!
  
  var availableQuizzes: Results<Quiz>!
  var finishedQuizzes: Results<Quiz>!
  
  override func loadView() {
    super.loadView()
    view.backgroundColor = UIColor.groupTableViewBackgroundColor()
    tableView = UITableView(frame: view.frame, style: .Grouped).then {
      $0.rowHeight = 96
      $0.tableFooterView = UIView()
      $0.setEditing(false, animated: false)
      $0.registerClass(QuizTableCell.self, forCellReuseIdentifier: QuizTableCell.id)
    }
    tableView.addSubview(refreshControl)
    view.addSubview(tableView)
    tableView.snp_makeConstraints {
      $0.top.left.right.equalTo(view)
      $0.bottom.equalTo(view).offset(-globalTabbarHeight)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    realm = try! Realm()
    tableView.delegate = self
    tableView.dataSource = self
    if let editionManager = SessionManager.instance.editionManager {
      availableQuizzes = realm.objects(Quiz).filter("editionId == \(editionManager.editionId) AND mock == false AND status != \(QuizStatus.Solved.rawValue) AND dueDate > %@", NSDate()).sorted("startDate")
      finishedQuizzes = realm.objects(Quiz).filter("editionId == \(editionManager.editionId) AND mock == false AND status == \(QuizStatus.Solved.rawValue)").sorted("dueDate", ascending: false)
      refreshQuizzes()
      refreshControl.addTarget(self, action: "refreshQuizzes", forControlEvents: .ValueChanged)
    }
    // Do any additional setup after loading the view.
  }
  
  func refreshQuizzes() {
    refreshControl.beginRefreshing()
    API.instance.getAvailableQuizzes()
      .subscribe(onNext: { [weak self] response in
        guard let SELF = self else {
          return
        }
        let realm = try! Realm()
        if let quizzes = response.data where response.status == 200 {
          let newQuizzes = quizzes.filter { quiz in
            return  realm.objectForPrimaryKey(Quiz.self, key: quiz.id) == nil
          }
          try! realm.write {
            realm.add(newQuizzes)
          }
        }
        Dispatcher.main {
          SELF.realm.refresh()
          SELF.tableView.reloadData()
          SELF.refreshControl.endRefreshing()
        }
        }, onError: { error in
          Dispatcher.main {
            self.refreshControl.endRefreshing()
          }
          
      }).addDisposableTo(disposeBag)
  }
  
  
  func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return itemInfo
  }
  
  
  
  // MARK: TableView DataSource
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    var sections = 0
    if availableQuizzes.count > 0 {
      sections++
    }
    if finishedQuizzes.count > 0 {
      sections++
    }
    return sections
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if availableQuizzes.count > 0 && section == 0 {
      return availableQuizzes.count
    }
    return finishedQuizzes.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(QuizTableCell.id) as! QuizTableCell
    let quiz = availableQuizzes.count > 0 && indexPath.section == 0 ? availableQuizzes[indexPath.row] : finishedQuizzes[indexPath.row]
    cell.bindTo(quiz)
    return cell
  }
  
  // MARK: - TableView Delegate
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 120
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return availableQuizzes.count > 0  && section == 0 ? "출제된 시험" : "응시 완료 시험"
  }
  
  func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
    tableView.cellForRowAtIndexPath(indexPath)!.backgroundColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 0.3)
  }
  
  func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
    tableView.cellForRowAtIndexPath(indexPath)!.backgroundColor = UIColor.whiteColor()
  }
  
  /// Select item at row in tableView.
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let quiz: Quiz = {
      if availableQuizzes.count > 0 && indexPath.section == 0 {
        return availableQuizzes[indexPath.row]
      }
      return finishedQuizzes[indexPath.row]
    }()
    // check if it's okay to take
    if quiz.status != QuizStatus.Solved.rawValue {
      if quiz.startDate > NSDate() {
        Whispers.error("\(quiz.startDate.timespan)에 응시할 수 있습니다.", self.navigationController)
        return
      } else if quiz.dueDate < quiz.startDate {
        Whispers.error("응시 가능시간이 아닙니다.", self.navigationController)
        return
      }
    }
    HUD.progress()
    if quiz.questions.count == 0 {

      API.instance.getQuiz(quiz.quizId)
        .subscribe(onNext: { [weak self] response in
          guard let SELF = self else {
            return
          }
          let realm = try! Realm()
          if let quiz = response.data where response.status == 200 {
            try! realm.write {
              realm.add(quiz, update: true)
            }
            let quizId = quiz.id
            let numberOfQuestions = quiz.questions.count
            Dispatcher.main {
              SELF.presentViewController(UINavigationController(rootViewController: ExamViewController(quizId: quizId, numberOfQuestions: numberOfQuestions)), animated: true, completion: nil)
              SELF.realm.refresh()
              HUD.hide()
            }
          }else {
            Dispatcher.main {
              HUD.error()
              Whispers.error("시험을 가져오는데 실패했습니다.", SELF.navigationController)
            }
          }
          }, onError: { error in
            
        })
        .addDisposableTo(disposeBag)
    } else {
      self.presentViewController(UINavigationController(rootViewController: ExamViewController(quizId: quiz.id, numberOfQuestions: quiz.questions.count)), animated: true, completion: nil)
    }
  }
}
