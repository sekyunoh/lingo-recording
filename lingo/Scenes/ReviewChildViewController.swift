//
//  ReviewChildViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/16/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import XLPagerTabStrip
import AVFoundation


class ReviewChildViewController: ViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
  
  var tableView: UITableView!
  
  let review: Review
  var realm: Realm!
  var itemInfo = IndicatorInfo(title: "View")
  
  var words: Results<Word>!
  var player: AVAudioPlayer?
  
  init(review: Review) {
    self.review = review
    self.itemInfo = IndicatorInfo(title: review.rawValue)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    tableView = UITableView().then {
      $0.rowHeight = 120
      $0.tableFooterView = UIView()
      $0.separatorInset = UIEdgeInsetsZero
      $0.alwaysBounceHorizontal = false
      $0.alwaysBounceVertical = false
      $0.setEditing(false, animated: false)
      $0.registerClass(WordTableCell.self, forCellReuseIdentifier: WordTableCell.name)
    }
    view.addSubview(tableView)
    tableView.snp_makeConstraints {
      $0.top.left.right.equalTo(view)
      $0.bottom.equalTo(view).offset(-globalTabbarHeight)
    }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    realm = try! Realm()
    
    if let edition = realm.objectForPrimaryKey(Edition.self, key: SessionManager.instance.editionManager!.editionId) {
      let wordIds: [Int] = {
        switch self.review {
        case .Starred:
          return edition.starredWords.map { $0.wordId }
        case .Learned:
          return edition.learnedWords.map { $0.wordId }
        case .WrongLearned:
          return edition.wrongLearningWords.map { $0.wordId }
        default:
          return [Int]()
        }
      }()
      words = realm.objects(Word).filter("id IN %@", wordIds)
      tableView.delegate = self
      tableView.dataSource = self
    }
    
  }
  
  // MARK: TableView
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return words.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let word = words[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(WordTableCell.name) as! WordTableCell
    cell.bindTo(word)
    return cell
  }
  
  // MARK: - TableView Delegate
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 120
  }
  
  /// Select item at row in tableView.
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let word = words[indexPath.row]
    playAudio(word.filename)
  }
  
  func playAudio(filename: String) {
    if let player = player where player.playing {
      player.stop()
    }
    SessionManager.instance.editionManager?.audio(filename)
      .subscribe(onNext: { player in
        if let player = player {
          player.play()
          self.player = player
        }
        }, onError: { error in
          dispatch_async(dispatch_get_main_queue()) {
            Whispers.error("발음 재생을 실패하였습니다.", self.navigationController)
          }
      }).addDisposableTo(disposeBag)
  }
  
  
  
  // MARK: - IndicatorInfoProvider
  
  func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    return itemInfo
  }
  
  
  
}


