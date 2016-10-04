
//
//  LearningStep1ViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/7/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
  import RxSwift
#endif
import RealmSwift
import ZLSwipeableViewSwift
import AVFoundation


class LearningStep1ViewController: ViewController, RestudyDelegate {
  
  var swipeableView: ZLSwipeableView!
  var progressView: UIProgressView!
  
  var debugLabel: UILabel?
  
  var realm: Realm!
  var words: [Word]!
  var cardViewIndex = 0
  
  var activeWordIds = [Int]()
  
  var player: AVAudioPlayer?
  
  var learningManager: LearningManager? {
    return SessionManager.instance.editionManager?.learningManager
  }
  
  
  override func loadView() {
    super.loadView()
    navigationController?.navigationBar.translucent = false
    view.backgroundColor = App.windowBackgroundColor
    view.clipsToBounds = true
    swipeableView = ZLSwipeableView().then {
      $0.numberOfActiveView = UInt(2)
      $0.allowedDirection = .Horizontal
    }
    view.addSubview(swipeableView)
    
    swipeableView.snp_makeConstraints {
      $0.top.equalTo(view).offset(20)
      $0.left.equalTo(view).offset(20)
      $0.right.equalTo(view).offset(-20)
      $0.bottom.equalTo(view).offset(-20)
    }
    
    
    progressView = UIProgressView().then {
      $0.progressViewStyle = .Bar
      $0.tintColor = App.secondaryColor
      $0.backgroundColor = App.lightColor
    }
    
    view.addSubview(progressView)
    progressView.snp_makeConstraints {
      $0.width.bottom.equalTo(view)
      $0.height.equalTo(10)
    }
    if debug {
      debugLabel = UILabel().then {
        $0.font = UIFont.systemFontOfSize(14)
        $0.numberOfLines = 0
        $0.lineBreakMode = .ByWordWrapping
      }
      view.addSubview(debugLabel!)
      debugLabel!.snp_makeConstraints {
        $0.width.equalTo(view)
        $0.bottom.equalTo(progressView.snp_top)
      }
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    log.debug("viewDidLoad")
    guard let learningManager = learningManager else {
      self.dismissViewControllerAnimated(false, completion: nil)
      return
    }
    self.title = learningManager.groupName
    realm = try! Realm()
    // Do any additional setup after loading the view.
    Whispers.murmur( "암기한 단어는 오른쪽, 다음 단어는 왼쪽으로 넘겨주세요.")
    setup()
    swipeableView.numberOfHistoryItem = UInt(words.count)
    swipeableView.didTap = didTap
    swipeableView.didDoubleTap = didDoubleTap
    swipeableView.didSwipe = didSwipe
  }
  
  func setup(restart: Bool = false) {
    cardViewIndex = 0
    activeWordIds.removeAll()
    words = realm.objects(Word).filter("id IN %@", learningManager!.learningWordIds).map { $0 }
    learningManager!.learnedWordIds.removeAll()
    if let firstWord = words.first {
      playAudio(firstWord.filename)
    }
    
    if restart {
      swipeableView.discardViews()
      swipeableView.loadViews()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    log.debug("viewWillAppear")
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "끝내기", style: .Plain, target: self, action: "didTapBack:")
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "1단계", style: .Plain, target: nil, action: "")
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    log.debug("viewDidAppear")
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    log.debug("viewDidLayoutSubviews")
    if swipeableView.nextView == nil {
      log.debug("nextView")
      swipeableView.nextView = {
        return self.nextCardView()
      }
    }
  }
  
  // MARK: SwipeableView Delegate
  
  func nextCardView() -> UIView? {
    if words.isEmpty {
      // display next step
      return nil
    }
    let currentCardViewIndex = cardViewIndex < words.count ? cardViewIndex  : 0
    let word = words[currentCardViewIndex]
    if activeWordIds.contains(word.id) {
      return nil
    }
    
    let cardView = FlashcardView(frame: swipeableView.bounds)
    updateCardView(cardView, word: word)
    cardViewIndex = currentCardViewIndex + 1
    return cardView
  }
  
  func updateCardView(cardView: FlashcardView, word: Word) {
    let starredWord = realm.objects(StarredWord).filter("editionId == \(SessionManager.instance.editionManager!.editionId) AND wordId == \(word.id)").first
    cardView.bindTo(word: word, starred: starredWord != nil)
  }
  
  // MARK: SwipeableView Actions
  
  func didStart(view: UIView, atLocation: CGPoint) -> () {
    // TODO: Display the view
  }
  
  func didEnd(view: UIView, atLocation: CGPoint) -> () {
    
  }
  
  func didSwipe(view: UIView, inDirection: Direction, directionVector: CGVector) -> () {
    
    
    guard let cardView = view as? FlashcardView where !words.isEmpty else {
      
      return
    }
    let word = cardView.word
   // print("the word is \(word)")
    if inDirection == .Right {
      learningManager!.learnedWordIds.append(word.id)
      if let learnedWordIndex = words.indexOf(word) where learnedWordIndex >= 0 {
//        Whispers.info("암기한 단어: \(word.word)", self.navigationController)
        
        words.removeAtIndex(learnedWordIndex)
        if words.isEmpty {
          swipeableView.discardViews()
          //goToNextStep()
            switch word.form {
            case "talk":
                print("it is talk or idiom")
                goToStepThree()
                
            case "idiom":
                print("it is talk or idiom")
                goToStepThree()
                
            default:
                print("it is a vocabulary")
                goToNextStep()
            }
          
        }else {
          cardViewIndex = learnedWordIndex
          for view in swipeableView.activeViews() {
            guard let cardView = view as? FlashcardView else {
              continue
            }
            let newCardViewIndex = cardViewIndex < words.count ? cardViewIndex : 0
            let word = words[newCardViewIndex]
            updateCardView(cardView, word: word)
            cardViewIndex = newCardViewIndex + 1
          }
        }
      }
      updateProgressView()
    }
    
    if let newCardView = swipeableView.activeViews().first as? FlashcardView {
      playAudio(newCardView.word.filename)
    }
    
  }
  
  func updateProgressView() {
    progressView.setProgress(Float(learningManager!.learnedWordIds.count) / Float(learningManager!.learningWordIds.count), animated: true)
    if let debugLabel = debugLabel {
      let activeViewWordIds = swipeableView.activeViews().map { activeView -> Int in
        let cardView = activeView as! FlashcardView
        return cardView.word.id
      }
      let wordIds = words.map { $0.id }
      debugLabel.text = "activeVieWords=\(activeViewWordIds)\nwords=\(wordIds)\nlearned=\(learningManager!.learnedWordIds)"
    }
  }
  
  
  func didTap(view: UIView, atLocation: CGPoint) -> (){
    if let flashCardView =  view as? FlashcardView{
      log.debug("didTap \(atLocation)")
      if flashCardView.starView.frame.contains(atLocation) {
        toggleStar(flashCardView)
      } else if flashCardView.wordImageView.bounds.contains(atLocation) {
        log.debug("tapped image")
        playAudio(flashCardView.word.filename)
      } else {
        log.debug("tapped bottom container")
      }
      
    }
  }
  
  func toggleStar(flashcardView: FlashcardView) {
    let wordId = flashcardView.word.id
    let starredWord = flashcardView.starred
    
    if starredWord {
      SessionManager.instance.editionManager?.unstarWord(wordId)
    } else {
      SessionManager.instance.editionManager?.starWord(wordId)
    }
    flashcardView.updateStarred(!starredWord)
    
  }
  
  func didDoubleTap(view: UIView, atLocation: CGPoint) -> () {
    if let previousTopCardView = swipeableView.activeViews().first as? FlashcardView {
      swipeableView.rewind()
      if let topCardView = swipeableView.activeViews().first as? FlashcardView {
        if let learnedWordIndex = learningManager!.learnedWordIds.indexOf(topCardView.word.id) {
          learningManager!.learnedWordIds.removeAtIndex(learnedWordIndex)
          if let originalWordIndex = words.indexOf(previousTopCardView.word) {
            words.insert(topCardView.word, atIndex: originalWordIndex)
          }
          updateProgressView()
        }
        playAudio(topCardView.word.filename)
      }
      
    }
  }
  
  // MARK: NavigationItem
  
  func didTapBack(sender: UIBarButtonItem) {
    $.wireframe.promptFor(self, title: "학습 종료", message:"학습을 종료하시겠습니까?", cancelAction: "취소", actions: ["종료"])
      .subscribeNext { [weak self] action in
        guard let SELF = self else {
          return
        }
        if action == "종료" {
          SELF.dismissViewControllerAnimated(true, completion: nil)
        }
      }.addDisposableTo(disposeBag)
    
  }
  
  func goToNextStep() {
    $.wireframe.promptFor(self, title: "1단계 단어 암기 완료", message: "2단계로 넘어가시겠습니까?\n2단계 - 그림 보고 단어 선택", cancelAction: "다시 암기", actions: ["다음 단계로"])
      .subscribeNext { [weak self] action in
        guard let SELF = self else {
          return
        }
        
        switch action {
        case "다시 암기" :
          SELF.setup(true)
        case "다음 단계로":
          //          SELF.title = "1단계"
          //          SELF.presentViewController(UINavigationController(rootViewController: LearningStep2ViewController()), animated: false, completion: nil)
          let step2VC = LearningStep2ViewController()
          step2VC.restudyDelegate = self
          SELF.navigationController?.pushViewController(step2VC, animated: true, completion: nil)
          //          SELF.navigationController?.pushViewController(LearningStep2ViewController(), animated: true, completion: nil)
        default:
          break
        }
        SELF.log.debug("action=\(action)")
      }.addDisposableTo(disposeBag)
    
  }
    
    func goToStepThree() {
        $.wireframe.promptFor(self, title: "1단계 단어 암기 완료", message: "다음단계로 넘어가시겠습니까?\n다음단계 - 그림 보고 문장 말하기", cancelAction: "다시 암기", actions: ["다음 단계로"])
            .subscribeNext { [weak self] action in
                guard let SELF = self else {
                    return
                }
                
                switch action {
                case "다시 암기" :
                    SELF.setup(true)
                case "다음 단계로":
                    let step3VC = LearningStep3ViewController()
                    step3VC.restudyDelegate = self
                    SELF.navigationController?.pushViewController(step3VC, animated: true, completion: nil)
                default:
                    break
                }
                SELF.log.debug("action=\(action)")
            }.addDisposableTo(disposeBag)
        
    }
  
  
  func playAudio(filename: String) {
    if let player = player where player.playing {
      player.stop()
    }
    SessionManager.instance.editionManager?.audio(filename)
      .subscribe(onNext: { player in
        if let player = player {
          print("play=\(filename)")
          player.play()
          self.player = player
        }
        }, onError: { error in
          dispatch_async(dispatch_get_main_queue()) {
            Whispers.error("발음 재생을 실패하였습니다.", self.navigationController)
          }
      }).addDisposableTo(disposeBag)
  }
  
  func onRestudy() {
    progressView.setProgress(0, animated: false)
    setup(true)
  }
  
}
