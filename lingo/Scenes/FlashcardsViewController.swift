//
//  FlashcardsViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/1/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift
import SnapKit
import Material
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif
import RealmSwift
import AVFoundation
import SwiftyUserDefaults

class FlashcardsViewController: ViewController {
  var dismissViewControllerBlock: (() -> ())!
  
  var swipeableView: ZLSwipeableView!
  
  let viewModel: FlashcardsViewModel
  
  var realm: Realm!
  let groups: Results<PublishedGroup>!
  
  var player: AVAudioPlayer?
  
  var indexPath: NSIndexPath! {
    didSet {
      if viewModel.indexPath.value != indexPath {
        viewModel.indexPath.value = indexPath
      }
    }
  }
  var nextTrackingIndexPath: NSIndexPath!
  
  let autoPlay: Bool
  let repeatCount: Int
  let delay: Int
  
  var currentRepeatCount = 0
  
  var timerDisposable: Disposable?
  
  var topCardView: FlashcardView? {
    return swipeableView.activeViews().first as? FlashcardView
  }
  
  
  init(viewModel: FlashcardsViewModel!, groups: Results<PublishedGroup>!) {
    self.viewModel = viewModel
    self.groups = groups
    self.autoPlay = Defaults[.autoPlay]
    self.repeatCount = Defaults[.repeatCount]
    self.delay = Defaults[.delay]
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func loadView() {
    super.loadView()
    log.debug("loadView")
    indexPath = viewModel.indexPath.value
    nextTrackingIndexPath = indexPath
    view.backgroundColor = App.windowBackgroundColor
    swipeableView = ZLSwipeableView().then {
      $0.allowedDirection = .All
      $0.numberOfActiveView = UInt(2)
    }
    
    view.addSubview(swipeableView)
    swipeableView.snp_makeConstraints {
      $0.top.equalTo(view).offset(globalNavigationBarHeight+20)
      $0.left.equalTo(view).offset(20)
      $0.right.equalTo(view).offset(-20)
      $0.bottom.equalTo(view).offset(-20)
    }
    view.clipsToBounds = true
    swipeableView.didTap = didTap
    swipeableView.didDoubleTap = didDoubleTap
    swipeableView.didSwipe = didSwipe
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    log.debug("viewDidLoad")
    viewModel.indexPathDriver.driveNext { newIndexPath in
      if let indexPath = self.indexPath where newIndexPath != indexPath {
        self.indexPath = newIndexPath
        self.nextTrackingIndexPath = newIndexPath
        self.swipeableView.discardViews()
        self.swipeableView.loadViews()
        if let selectedFlashCardView = self.swipeableView.activeViews().first as? FlashcardView {
          self.playAudio(selectedFlashCardView.word.filename)
        }
      }
      }.addDisposableTo(disposeBag)
    title = App.Title.flashcards
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "didTapBack:")
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "단어목록", style:  .Plain, target: self, action: "didTapSideBar:")
    realm = try! Realm()
    swipeableView.previousView = {
      return self.previousCardView()
    }
    let word = groups[indexPath.section].groupWords[indexPath.row]
    playAudio(word.word.filename)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.barTintColor = Theme.flashcards
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    log.debug("viewDidLayoutSubviews")
    swipeableView.nextView = {
      return self.nextCardView()
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    Defaults[viewModel.flashcardsRow] = indexPath.row
    Defaults[viewModel.flashcardsSection] = indexPath.section
    log.debug("indexPath=\(self.indexPath)")
  }
  
  func didSwipe(view: UIView, inDirection: Direction, directionVector: CGVector) -> () {
    
    if let newCardView = topCardView {
      playAudio(newCardView.word.filename)
      self.indexPath = newCardView.indexPath
      log.debug("swipe indexPath=\(newCardView.indexPath)")
    }
    
  }
  
  
  func didTapBack(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func didTapSideBar(sender: UIBarButtonItem) {
    if let slideNavigationVC = self.parentViewController?.parentViewController as? NavigationDrawerController {
      slideNavigationVC.openRightView()
    }
  }
  
  func previousCardView() -> UIView? {
    if let groups = groups, let topCardView = swipeableView.activeViews().first as? FlashcardView {
      let previousViewIndexPath: NSIndexPath = {
        let indexPath = topCardView.indexPath
        if indexPath.row - 1 >= 0 {
          return NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
        }
        if indexPath.section - 1 >= 0 {
          return NSIndexPath(forRow: self.groups[indexPath.section - 1].groupWords.count - 1, inSection: indexPath.section - 1)
        }
        return NSIndexPath(forRow: groups[groups.count - 1].groupWords.count - 1, inSection: groups.count - 1)
      }()
      
      let group = groups[previousViewIndexPath.section]
      let word = group.groupWords[previousViewIndexPath.row]
      let cardView = FlashcardView(frame: swipeableView.bounds)
      cardView.bindTo(previousViewIndexPath, word: word.word, starred: realm.objects(StarredWord).filter("editionId == \(viewModel.editionId) AND wordId == \(word.id)").first != nil)
      self.indexPath = previousViewIndexPath
      return cardView
    }
    return nil
  }
  
  
  func nextCardView() -> UIView? {
    if let groups = groups {
      self.log.debug("nextTrackingIndexPath=\(self.nextTrackingIndexPath)")
      let group = groups[nextTrackingIndexPath.section]
      let word = group.groupWords[nextTrackingIndexPath.row]
      let cardView = FlashcardView(frame: swipeableView.bounds)
      cardView.bindTo(nextTrackingIndexPath, word: word.word, starred: realm.objects(StarredWord).filter("editionId == \(viewModel.editionId) AND wordId == \(word.id)").first != nil)
      if nextTrackingIndexPath.row + 1 < group.numberOfWords {
        self.nextTrackingIndexPath = NSIndexPath(forRow: nextTrackingIndexPath.row + 1, inSection: nextTrackingIndexPath.section)
      } else if indexPath.section + 1 < groups.count {
        self.nextTrackingIndexPath = NSIndexPath(forRow: 0, inSection: nextTrackingIndexPath.section + 1)
      } else{
        self.nextTrackingIndexPath = NSIndexPath(forRow: 0, inSection: 0)
      }
      return cardView
    }
    return nil
  }
  
  func didTap(view: UIView, atLocation: CGPoint) -> (){
    if let flashCardView =  view as? FlashcardView{
      log.debug("didTap \(atLocation)")
      if flashCardView.starView.frame.contains(atLocation) {
        log.debug("toggle star")
      } else if flashCardView.wordImageView.bounds.contains(atLocation) {
        log.debug("tapped image")
        playAudio(flashCardView.word.filename)
      } else {
        log.debug("tapped bottom container")
      }
      
    }
  }
  
  func didDoubleTap(view: UIView, atLocation: CGPoint) -> (){
    swipeableView.rewind()
    if let cardView = swipeableView.activeViews().first as? FlashcardView {
      playAudio(cardView.word.filename)
      self.indexPath = cardView.indexPath
      log.debug("swipe indexPath=\(cardView.indexPath)")
    }
  }
  
  
  func playAudio(filename: String) {
    if let player = player where player.playing {
      player.stop()
    }
    SessionManager.instance.editionManager?.audio(filename)
      .subscribe(onNext: { player in
        if let player = player {
          print("play!")
          player.play()
          self.player = player
        }
        }, onError: { error in
          dispatch_async(dispatch_get_main_queue()) {
            Whispers.error("발음 재생을 실패하였습니다.", self.navigationController)
          }
      }).addDisposableTo(disposeBag)
  }
  
}
