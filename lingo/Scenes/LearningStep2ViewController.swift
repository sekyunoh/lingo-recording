//
//  LearningStep2ViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/7/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif
import RealmSwift
import ZLSwipeableViewSwift
import AVFoundation
import Then


class LearningStep2ViewController: ViewController, AVAudioPlayerDelegate, RestudyDelegate {
  var debugLabel: UILabel?
  var emptyView: UIView!
  var cardView: UIView!
  var containerView: UIView!
  var wordImageView: UIImageView!
  var starView: UIImageView!
  var definitionLabel: UILabel!
  var choiceButtons: [ChoiceButton]!
  
  var loadImageDisposable: Disposable?
  
  var realm: Realm!
  var words: [Word]!
  var currentWordIndex = 0
  
  var player: AVAudioPlayer?
  
  var answerIndicatorView: AnswerIndicatorView!
  
  var restudyDelegate: RestudyDelegate?
  
  var learningManager: LearningManager? {
    return SessionManager.instance.editionManager?.learningManager
  }
  
  var editionId: Int!
  
  
  override func loadView() {
    super.loadView()
    navigationController?.navigationBar.translucent = false
    view.backgroundColor = App.windowBackgroundColor
    emptyView = UIView()
    view.addSubview(emptyView)
    emptyView.snp_makeConstraints {
      $0.top.left.right.bottom.equalTo(view)
      $0.size.equalTo(view)
    }
    cardView = UIView().then {
      $0.layer.shadowColor = UIColor.blackColor().CGColor
      $0.layer.shadowOpacity = 0.25
      $0.layer.shadowOffset = CGSizeMake(0, 1.5)
      $0.layer.shadowRadius = 4.0
      $0.layer.shouldRasterize = true
      $0.layer.rasterizationScale = UIScreen.mainScreen().scale
      $0.layer.cornerRadius = 10.0;
      $0.backgroundColor = UIColor.whiteColor()
    }
    
    emptyView.addSubview(cardView)
    cardView.snp_makeConstraints {
      $0.top.left.equalTo(view).offset(20)
      $0.bottom.right.equalTo(view).offset(-20)
    }
    
    containerView = UIView().then {
      $0.layer.cornerRadius = 10.0;
      $0.clipsToBounds = true
    }
    cardView.addSubview(containerView)
    containerView.snp_makeConstraints {
      $0.top.left.right.bottom.equalTo(cardView)
      $0.size.equalTo(cardView)
    }
    wordImageView = UIImageView().then {
      $0.contentMode = .ScaleToFill
    }
    containerView.addSubview(wordImageView)
    wordImageView.snp_makeConstraints {
      $0.top.left.equalTo(containerView)
      $0.width.equalTo(containerView.snp_width)
      $0.height.equalTo(containerView.snp_width)
    }
    
    starView = UIImageView().then {
      $0.userInteractionEnabled = true
    }
    containerView.addSubview(starView)
    
    starView.snp_makeConstraints {
      $0.size.equalTo(48)
      $0.left.top.equalTo(wordImageView)
    }
    
    definitionLabel = UILabel().then {
      $0.font = UIFont.systemFontOfSize(18.0)
      $0.numberOfLines = 1
      $0.textAlignment = .Center
      $0.textColor = UIColor.whiteColor()
      $0.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
    }
    containerView.addSubview(definitionLabel)
    definitionLabel.snp_makeConstraints {
      $0.width.equalTo(containerView)
      $0.bottom.equalTo(wordImageView)
      $0.left.right.equalTo(containerView)
      $0.height.equalTo(36)
    }
    
    let choicesHolder = UIView()
    containerView.addSubview(choicesHolder)
    choicesHolder.snp_makeConstraints {
      $0.width.equalTo(containerView)
      $0.left.bottom.right.equalTo(containerView)
      $0.top.equalTo(wordImageView.snp_bottom)
    }
    
    choiceButtons = [ChoiceButton]()
    for _ in 1...4  {
      choiceButtons.append(ChoiceButton())
    }
    var upperView: UIView?
    for choiceButton in choiceButtons {
      choicesHolder.addSubview(choiceButton)
      choiceButton.snp_makeConstraints {
        $0.left.right.equalTo(choicesHolder)
        $0.width.equalTo(choicesHolder)
        if choiceButton == choiceButtons.last {
          $0.height.equalTo(choicesHolder).dividedBy(4)
        } else {
          $0.height.equalTo(choicesHolder).dividedBy(4).offset(-1)
        }
        if let upperView = upperView {
          $0.top.equalTo(upperView.snp_bottom)
        } else {
          $0.top.equalTo(choicesHolder)
        }
      }
      if choiceButton == choiceButtons.last {
        break
      }
      let divider = UIView().then {
        $0.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
      }
      choicesHolder.addSubview(divider)
      divider.snp_makeConstraints {
        $0.left.right.equalTo(choicesHolder)
        $0.width.equalTo(choicesHolder)
        $0.height.equalTo(1)
        $0.top.equalTo(choiceButton.snp_bottom)
      }
      upperView = divider
    }
    
    if debug {
      debugLabel = UILabel().then {
        $0.font = UIFont.systemFontOfSize(14)
        $0.numberOfLines = 0
        $0.lineBreakMode = .ByWordWrapping
      }
      containerView.addSubview(debugLabel!)
      debugLabel!.snp_makeConstraints {
        $0.top.left.equalTo(wordImageView)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let learningManager = learningManager else {
      self.dismissViewControllerAnimated(false, completion: nil)
      return
    }
    let answerIndicatorViewHeight = CGFloat(16)
    answerIndicatorView = AnswerIndicatorView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: answerIndicatorViewHeight), withQuestions: learningManager.learningWordIds.count)
    emptyView.addSubview(answerIndicatorView)
    answerIndicatorView.snp_makeConstraints {
      $0.bottom.equalTo(view).offset(-1)
      $0.left.right.equalTo(view)
      $0.height.equalTo(16)
      
    }
    self.title = learningManager.groupName
    Whispers.murmur("그림과 뜻을 보고 연상되는 단어를 선택해 주세요.")
    editionId = SessionManager.instance.editionManager!.editionId
    realm = try! Realm()
    currentWordIndex = 0
    words = realm.objects(Word).filter("id IN %@", learningManager.learningWordIds).map { $0 }
    if !learningManager.keepOrder {
      words.shuffleInPlace()
    }
    learningManager.learnedWordIds.removeAll()
    
    updateCurrentWord()
    for choiceButton in choiceButtons {
      choiceButton.addTarget(self, action: #selector(LearningStep2ViewController.didTapChoice(_:)), forControlEvents: .TouchUpInside)
    }
    
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(LearningStep2ViewController.toggleStarred))
    singleTap.numberOfTapsRequired = 1
    starView.addGestureRecognizer(singleTap)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "끝내기", style: .Plain, target: self, action: #selector(LearningStep2ViewController.didTapBack(_:)))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "2단계", style: .Plain, target: nil, action: Selector(""))
    navigationItem.hidesBackButton = true
    answerIndicatorView.layoutIfNeeded()
  }
  
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    answerIndicatorView.collectionViewLayout.invalidateLayout()
  }
  
  func updateCurrentWord() {
    let word = words[currentWordIndex]
    answerIndicatorView.moveCurrentIndex(currentWordIndex)
    if loadImageDisposable != nil {
      loadImageDisposable!.dispose()
    }
    loadImageDisposable = wordImageView.iv_setImageWithFilename(word.filename)
    definitionLabel.text = word.krDefinition
    updateStarred(realm.objects(StarredWord).filter("wordId == \(word.id) and editionId == \(editionId)").first != nil)
    debugLabel?.text = "\(word.id)"
    
    
    if let answerManager = SessionManager.instance.editionManager?.answerManager {
      for (choice, choiceButton) in  zip(answerManager.generateAnswer(word), choiceButtons) {
        choiceButton.updateChoice(choice, type: .DefinitionToWord)
      }
    }
  }
  
  func updateStarred(starred: Bool ) {
    if starred {
      starView.image = UIImage(named: "star")
    } else {
      starView.image = UIImage(named: "star-outline")
    }
  }
  
  func toggleStarred() {
    let word = words[currentWordIndex]
    let starred = realm.objects(StarredWord).filter("wordId == \(word.id) and editionId == \(editionId)").first != nil
    if starred {
      SessionManager.instance.editionManager?.unstarWord(word.id)
    } else {
      SessionManager.instance.editionManager?.starWord(word.id)
    }
    updateStarred(!starred)
  }
  
  func didTapChoice(choiceButton: ChoiceButton) {
    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    let currentWord = words[currentWordIndex]
    
    let answerStatus = currentWord.word == choiceButton.choice.choice ? AnswerStatus.Correct : AnswerStatus.Incorrect
    answerIndicatorView.updateAnswerStatus(answerStatus, withIndex: currentWordIndex)
    choiceButton.updateChoiceStatus(answerStatus)
    
    for choiceButton in choiceButtons {
      choiceButton.showAnswerLabel()
      if answerStatus == .Incorrect && currentWord.word == choiceButton.choice.choice {
        choiceButton.updateChoiceStatus(.Correct)
      }
    }
    playAudio(currentWord.filename)
    
    if answerStatus == .Correct {
      learningManager?.learnedWordIds.append(currentWord.id)
      //      updateProgressView()
      if learningManager!.keepOrder {
        SessionManager.instance.editionManager?.learnWord(learningManager!.groupId, wordId: currentWord.id)
      }
    }
    
  }
  
  // MARK: NavigationItem
  
  func didTapBack(sender: UIBarButtonItem) {
    $.wireframe.promptFor(self, title: "학습을 종료", message:"학습을 종료하시겠습니까?", cancelAction: "취소", actions: ["종료"])
      .subscribeNext { [weak self] action in
        guard let SELF = self else {
          return
        }
        if action == "종료" {
          SELF.dismissViewControllerAnimated(true, completion: nil)
        }
      }.addDisposableTo(disposeBag)
    
  }
  
  func playAudio(filename: String) {
    if let player = player where player.playing {
      player.stop()
    }
    SessionManager.instance.editionManager?.audio(filename)
      .subscribe(onNext: { player in
        if let player = player {
          print("play!")
          player.delegate = self
          player.play()
          self.player = player
        }
        }, onError: { error in
          dispatch_async(dispatch_get_main_queue()) {
            Whispers.error("발음 재생을 실패하였습니다.", self.navigationController)
          }
      }).addDisposableTo(disposeBag)
  }
  
  // MARK: AVAudioPlayerDelegate
  func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    if currentWordIndex + 1 < words.count {
      currentWordIndex += 1
      updateCurrentWord()
    } else {
      // check if the user finishes all
      if learningManager!.learnedWordIds.count == learningManager!.learningWordIds.count {
        if learningManager!.keepOrder {
          // learn group and finish
          showLearnedDialog()
        } else {
          // go to next step
          goToNextStep()
        }
      } else {
        restudy()
      }
    }
    UIApplication.sharedApplication().endIgnoringInteractionEvents()
  }
  
  func showLearnedDialog() {
    HUD.message("학습 데이터를 전송중입니다.")
    SessionManager.instance.editionManager!.learnGroup(learningManager!.groupId)
    $.wireframe.promptFor(self, title: "학습 완료", message: "\(learningManager!.groupName) 단원 학습을 완료하였습니다.", cancelAction: "끝내기", actions: [])
      .subscribeNext { _ in
        self.dismissViewControllerAnimated(true, completion: nil)
      }.addDisposableTo(disposeBag)
    HUD.hide()
  }
  
  func goToNextStep() {
    $.wireframe.promptFor(self, title: "2단계 단어 찾기 완료", message: "3단계로 넘어가시겠습니까?\n주관식이 남아있습니다.", cancelAction: nil, actions: ["다음 단계로"])
      .subscribeNext { [weak self] action in
        guard let SELF = self else {
          return
        }
        
        switch action {
        case "다음 단계로":
          //          SELF.title = "1단계"
          //          SELF.presentViewController(UINavigationController(rootViewController: LearningStep2ViewController()), animated: false, completion: nil)
          SELF.learningManager!.learningWordIds = SELF.learningManager!.notLearnedWordIds
          let step3VC = LearningStep3ViewController()
          step3VC.restudyDelegate = SELF.restudyDelegate
          SELF.navigationController?.pushViewController(step3VC, animated: true, completion: nil)
          //          SELF.navigationController?.pushViewController(LearningStep2ViewController(), animated: true, completion: nil)
        default:
          break
        }
        SELF.log.debug("action=\(action)")
      }.addDisposableTo(disposeBag)
    
  }
  
  func restudy() {
    if let learningManager = learningManager {
      let numberOfIncorrectWords = learningManager.learningWordIds.count - learningManager.learnedWordIds.count
      
      $.wireframe.promptFor(self, title: "다시 공부", message: "외우지 못한 단어가 \(numberOfIncorrectWords)개 있습니다. 다시 공부해 주세요.", cancelAction: nil, actions: ["다시 공부"])
        .subscribeNext { action in
          switch action {
          case "다시 공부":
            //          SELF.title = "1단계"
            //          SELF.presentViewController(UINavigationController(rootViewController: LearningStep2ViewController()), animated: false, completion: nil)
            let learningWordIds = Array(learningManager.learningWordIds)
            learningManager.learningWordIds.removeAll()
            for wordId in learningWordIds {
              if !learningManager.learnedWordIds.contains(wordId) {
                learningManager.learningWordIds.append(wordId)
              }
            }
            self.player?.delegate = nil
            self.player = nil
            if let delegate = self.restudyDelegate {
              delegate.onRestudy()
            }
            self.navigationController?.popViewControllerAnimated(true)
            
            //          SELF.navigationController?.popViewControllerAnimated(true)
            //          SELF.navigationController?.pushViewController(LearningStep2ViewController(), animated: true, completion: nil)
          default:
            break
          }
        }.addDisposableTo(disposeBag)
    }
  }
  
  
  func onRestudy() {
    if let delegate = self.restudyDelegate {
      delegate.onRestudy()
    }
  }
}
