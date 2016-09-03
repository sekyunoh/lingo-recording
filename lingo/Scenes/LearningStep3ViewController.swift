//
//  LearningStep2ViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/7/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
import Material
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif
import RealmSwift
import ZLSwipeableViewSwift
import AVFoundation


class LearningStep3ViewController: ViewController, AVAudioPlayerDelegate, UITextFieldDelegate {
  var debugLabel: UILabel?
  var emptyView: UIView!
  var cardView: UIView!
  var containerView: UIView!
  var wordImageView: UIImageView!
  var starView: UIImageView!
  var definitionHeader: UILabel!
  var definitionLabel: UILabel!
  var wordTextField: UITextField!
  
  var loadImageDisposable: Disposable?
  
  var restudyDelegate: RestudyDelegate?
  
  var realm: Realm!
  var words: [Word]!
  var answerCandidates: Set<String>!
  var currentWordIndex = 0
  
  var player: AVAudioPlayer?
  
  var answerIndicatorView: AnswerIndicatorView!
  
  var learningManager: LearningManager? {
    return SessionManager.instance.editionManager?.learningManager
  }
  
  var editionId: Int!
  
  var currentRetryCount = 0
  let maxRetryCount = 3
  
  
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
      $0.top.left.equalTo(emptyView).offset(20)
      $0.bottom.right.equalTo(emptyView).offset(-20)
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
      $0.userInteractionEnabled = true
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
    
    wordTextField = UITextField().then {
      $0.placeholder = "단어를 입력하세요."
      $0.textAlignment = .Center
      $0.font = UIFont.systemFontOfSize(18)
      $0.keyboardType = .ASCIICapable
      $0.autocorrectionType = .No
      $0.autocapitalizationType = .None
      $0.returnKeyType = .Done
      $0.clearButtonMode = .WhileEditing
      $0.layer.borderColor = UIColor.lightGrayColor().CGColor
      $0.layer.borderWidth = 1
      $0.layer.cornerRadius = 10
      $0.layer.masksToBounds = true
    }
    containerView.addSubview(wordTextField)
    
    wordTextField.snp_makeConstraints {
      $0.top.equalTo(wordImageView.snp_bottom).offset(12)
      $0.left.equalTo(containerView).offset(24)
      $0.right.equalTo(containerView).offset(-24)
      $0.height.equalTo(32)
    }
    
    definitionHeader = UILabel().then {
      $0.font = UIFont.boldSystemFontOfSize(18.0)
      $0.backgroundColor = UIColor.blackColor()
      $0.textColor = UIColor.whiteColor()
      $0.text = "뜻"
      $0.textAlignment = .Center
    }
    
    containerView.addSubview(definitionHeader)
    
    definitionHeader.snp_makeConstraints {
      $0.left.equalTo(wordImageView)
      $0.top.equalTo(wordTextField.snp_bottom).offset(24)
      $0.size.equalTo(28)
    }
    
    
    definitionLabel = UILabel().then {
      $0.font = UIFont.systemFontOfSize(18.0)
      $0.numberOfLines = 0
      $0.lineBreakMode = .ByWordWrapping
      //      $0.backgroundColor = UIColor.lightGrayColor()
    }
    containerView.addSubview(definitionLabel)
    definitionLabel.snp_makeConstraints {
      $0.left.equalTo(definitionHeader.snp_right).offset(8)
      $0.right.equalTo(containerView).offset(-8)
      $0.top.equalTo(definitionHeader).offset(4)
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
    wordTextField.delegate = self
    guard let learningManager = learningManager else {
      self.dismissViewControllerAnimated(false, completion: nil)
      return
    }
    let answerIndicatorViewHeight = CGFloat(16)
    answerIndicatorView = AnswerIndicatorView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: answerIndicatorViewHeight), withQuestions: learningManager.learningWordIds.count)
    emptyView.addSubview(answerIndicatorView)
    answerIndicatorView.snp_makeConstraints {
      $0.bottom.equalTo(emptyView).offset(-2)
      $0.left.right.equalTo(emptyView)
      $0.height.equalTo(16)
    }
    self.title = learningManager.groupName
    Whispers.murmur("그림과 뜻을 보고 연상되는 단어를 적어주세요.")
    editionId = SessionManager.instance.editionManager!.editionId
    realm = try! Realm()
    currentWordIndex = 0
    words = realm.objects(Word).filter("id IN %@", learningManager.learningWordIds).map { $0 }
    if !learningManager.keepOrder {
      words.shuffleInPlace()
    }
    learningManager.learnedWordIds.removeAll()
    updateCurrentWord()
    let singleTap = UITapGestureRecognizer(target: self, action:"didTapImage:")
    singleTap.numberOfTapsRequired = 1
    wordImageView.addGestureRecognizer(singleTap)
    let toggleStar = UITapGestureRecognizer(target: self, action: "toggleStarred")
    toggleStar.numberOfTapsRequired = 1
    starView.addGestureRecognizer(toggleStar)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "끝내기", style: .Plain, target: self, action: "didTapBack:")
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3단계", style: .Plain, target: nil, action: "")
    navigationItem.hidesBackButton = true
    answerIndicatorView.layoutIfNeeded()
  }
  
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    answerIndicatorView.collectionViewLayout.invalidateLayout()
  }
  
  func updateCurrentWord() {
    wordTextField.textColor = UIColor.blackColor()
    wordTextField.text = nil
    currentRetryCount = 0
    let word = words[currentWordIndex]
    answerCandidates = AnswerManager.getAnswerCandidates(word.word)
    answerIndicatorView.moveCurrentIndex(currentWordIndex)
    if loadImageDisposable != nil {
      loadImageDisposable!.dispose()
    }
    loadImageDisposable = wordImageView.iv_setImageWithFilename(word.filename)
    definitionLabel.text = word.krDefinition
    updateStarred(realm.objects(StarredWord).filter("wordId == \(word.id) and editionId == \(editionId)").first != nil)
    debugLabel?.text = "word=\(word.word) answerCandidates=\(answerCandidates)"
    let answer = word.word
    if answer.length > 2 {
      wordTextField.placeholder = answer.substringToIndex(answer.startIndex.advancedBy(2))
    }else {
      wordTextField.placeholder = nil
    }
    
    playAudio(word.filename, nextQuestionUponFinish: false)
  }
  
  func checkAnswer(input: String) {
    let currentWord = words[currentWordIndex]
    let answerStatus = AnswerManager.checkAnswer(input, answerCandidates: answerCandidates)
    if answerStatus == .Correct {
      wordTextField.textColor = App.primaryColor
      wordTextField.resignFirstResponder()
      answerIndicatorView.updateAnswerStatus(answerStatus, withIndex: currentWordIndex)
      playAudio(currentWord.filename, nextQuestionUponFinish: true)
      learningManager?.learnedWordIds.append(currentWord.id)
      SessionManager.instance.editionManager?.learnWord(learningManager!.groupId, wordId: currentWord.id)
    } else {
      currentRetryCount++
      if currentRetryCount < maxRetryCount {
        if maxRetryCount - currentRetryCount == 1 && currentWord.word.length > 2 {
          var hint = currentWord.word.substringToIndex(currentWord.word.startIndex.advancedBy(2))
          for _ in 0..<(currentWord.word.length - hint.length) {
            hint += "*"
          }
          Whispers.error("마지막 힌트는 \(hint)입니다.", self.navigationController)
        } else {
          Whispers.error("정답이 아닙니다.", self.navigationController)
        }
      } else {
        wordTextField.resignFirstResponder()
        wordTextField.textColor = App.errorColor
        wordTextField.text = currentWord.word
        answerIndicatorView.updateAnswerStatus(answerStatus, withIndex: currentWordIndex)
        playAudio(currentWord.filename, nextQuestionUponFinish: true)
        SessionManager.instance.editionManager?.wrongLearningWord(learningManager!.groupId, wordId: currentWord.id)
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
  
  func textFieldDidBeginEditing(textField: UITextField) {
    log.debug("beginEditing")
    animateViewMoving(true, moveValue: 80)
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    log.debug("endEditing")
    animateViewMoving(false, moveValue: 80)
  }
  
  // Lifting the view up
  func animateViewMoving (up:Bool, moveValue :CGFloat){
    let movementDuration:NSTimeInterval = 0.3
    let movement:CGFloat = ( up ? -moveValue : moveValue)
    UIView.beginAnimations( "animateView", context: nil)
    UIView.setAnimationBeginsFromCurrentState(true)
    UIView.setAnimationDuration(movementDuration )
    self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
    UIView.commitAnimations()
  }
  
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let answer = textField.text where answer.length > 0 {
      checkAnswer(answer)
      return true
    }
    Whispers.error("단어를 입력해 주세요.", self.navigationController)
    return false
  }
  
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
  
  func didTapImage(recognizer: UIPanGestureRecognizer) {
    let word = words[currentWordIndex]
    playAudio(word.filename)
    
  }
  
  func playAudio(filename: String, nextQuestionUponFinish: Bool = false) {
    if let player = player where player.playing {
      player.stop()
    }
    SessionManager.instance.editionManager?.audio(filename)
      .subscribe(onNext: { player in
        if let player = player {
          if nextQuestionUponFinish {
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            player.delegate = self
          } else {
            player.delegate = nil
          }
          player.play()
          self.player = player
        }
        }, onError: { error in
          if nextQuestionUponFinish {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
          }
          dispatch_async(dispatch_get_main_queue()) {
            Whispers.error("발음 재생을 실패하였습니다.", self.navigationController)
          }
      }).addDisposableTo(disposeBag)
  }
  
  // MARK: AVAudioPlayerDelegate
  func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    if currentWordIndex + 1 < words.count {
      currentWordIndex++
      updateCurrentWord()
    } else {
      // check if the user finishes all
      if learningManager!.learnedWordIds.count == learningManager!.learningWordIds.count {
        // learn group and finish
        showLearnedDialog()
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
  
  func restudy() {
    if let learningManager = learningManager {
      let numberOfIncorrectWords = learningManager.learningWordIds.count - learningManager.learnedWordIds.count
      
      $.wireframe.promptFor(self, title: "다시 공부", message: "외우지 못한 단어가 \(numberOfIncorrectWords)개 있습니다. 다시 공부해 주세요.", cancelAction: "학습 종료", actions: ["다시 공부"])
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
            learningManager.notLearnedWordIds = Array(learningManager.learningWordIds)
            self.player?.delegate = nil
            self.player = nil
            if let delegate = self.restudyDelegate {
              delegate.onRestudy()
            }
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            //          SELF.navigationController?.popViewControllerAnimated(true)
            //          SELF.navigationController?.pushViewController(LearningStep2ViewController(), animated: true, completion: nil)
          case "학습 종료":
            self.dismissViewControllerAnimated(true, completion: nil)
          default:
            break
          }
        }.addDisposableTo(disposeBag)
    }
  }
  
}
