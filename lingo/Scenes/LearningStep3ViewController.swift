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


class LearningStep3ViewController: ViewController, AVAudioPlayerDelegate,AVAudioRecorderDelegate,UITextFieldDelegate, OEEventsObserverDelegate {
    
  //자기 목소리 녹음
  @IBOutlet weak var btnPlay: UIButton!
  @IBOutlet weak var btnRecord: UIButton!
  var audioRecorder:AVAudioRecorder!
  var audioPlayer : AVAudioPlayer!
  let isRecorderAudioFile = false
  let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)),
                          AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
                          AVNumberOfChannelsKey : NSNumber(int: 1),
                          AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]
  
  var timer = NSTimer()
  var clickToRecord: UILabel!
  var itIsRecording: UILabel!
    
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
    
    
  var lmPath: String!
  var dicPath: String!
  var wordsToAppend: Array<String> = []
  var currentWord: String!
  var kLevelUpdatesPerSecond = 18
  var openEarsEventsObserver = OEEventsObserver()
  var startupFailedDueToLackOfPermissions = Bool()
  //var heardTextView: UITextView!
    var heardTextView: UITextField!
  //var statusTextView: UITextView!
  let image = UIImage(named: "Record Button.png")
  var recordButton = UIButton()
  var buttonFlashing = false

 
  
  override func loadView() {
    print("'this is a loadView'")
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
    
    
    recordButton = UIButton(frame: CGRect(x: self.view.frame.size.width / 2 - 70, y: self.view.frame.size.height - 220, width: 100, height: 65))
    recordButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    recordButton.setImage(image, forState: UIControlState.Normal)
    recordButton.addTarget(self, action: #selector(togglePlay), forControlEvents: .TouchUpInside)
    
    clickToRecord = UILabel().then {
        $0.font = UIFont.boldSystemFontOfSize(18.0)
        $0.backgroundColor = UIColor.whiteColor()
        $0.textColor = UIColor.blackColor()
        $0.text = "버튼을 눌러 녹음하세요"
        $0.textAlignment = .Center
    }
    
    containerView.addSubview(clickToRecord)
    clickToRecord.snp_makeConstraints {
        $0.left.equalTo(definitionHeader.snp_right).offset(8)
        $0.right.equalTo(containerView).offset(0)
        $0.top.equalTo(definitionHeader).offset(40)
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
    
  func togglePlay() {
    if !buttonFlashing {
        startFlashingbutton()
        startListening()
        //자기 목소리 녹음
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(URL: self.directoryURL()!,
                                                settings: recordSettings)
            audioRecorder.prepareToRecord()
        } catch {
        }
        do {
            //self.btnRecord.setTitle("Stop", forState: UIControlState.Normal)
            //self.btnPlay.enabled = false
            try audioSession.setActive(true)
            audioRecorder.record()
        } catch {
        }
        
    } else {
        stopFlashingbutton()
        stopListening()
        
    }
  }
    
    
  func startFlashingbutton() {
        
      buttonFlashing = true
      recordButton.alpha = 1
    
      UIView.animateWithDuration(0.5 , delay: 0.0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.AllowUserInteraction], animations: {
            
          self.recordButton.alpha = 0.1
        
          }, completion: {Bool in
      })
  }
    
  func stopFlashingbutton() {
        
      buttonFlashing = false
        
      UIView.animateWithDuration(0.1, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.BeginFromCurrentState], animations: {
            
          self.recordButton.alpha = 1
            
          }, completion: {Bool in
      })
  }
  
  override func viewDidLoad() {
    //print("'how often viewDidLoad is invoked '")
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
    Whispers.murmur("그림과 뜻을 보고 연상되는 단어를 적어주세요.")//not working?
    editionId = SessionManager.instance.editionManager!.editionId
    realm = try! Realm()
    currentWordIndex = 0
    words = realm.objects(Word).filter("id IN %@", learningManager.learningWordIds).map { $0 }
    print("'words in viewDidLoad' \(words)")
    
    //단어는 'n'
    switch words.first!.form {
    case "talk":
        containerView.addSubview(recordButton)
    case "idiom":
        containerView.addSubview(recordButton)
    default:
        break
    }
    
    if !learningManager.keepOrder {
      words.shuffleInPlace()
    }
    learningManager.learnedWordIds.removeAll()
    updateCurrentWord()
    let singleTap = UITapGestureRecognizer(target: self, action:#selector(LearningStep3ViewController.didTapImage(_:)))
    singleTap.numberOfTapsRequired = 1
    wordImageView.addGestureRecognizer(singleTap)
    let toggleStar = UITapGestureRecognizer(target: self, action: #selector(LearningStep3ViewController.toggleStarred))
    toggleStar.numberOfTapsRequired = 1
    starView.addGestureRecognizer(toggleStar)
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "끝내기", style: .Plain, target: self, action: #selector(LearningStep3ViewController.didTapBack(_:)))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "3단계", style: .Plain, target: nil, action: Selector(""))
    navigationItem.hidesBackButton = true
    answerIndicatorView.layoutIfNeeded()

    
  }
  
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    answerIndicatorView.collectionViewLayout.invalidateLayout()
  }
  
  func updateCurrentWord() {
    timer.invalidate()
    print("'updateCurrentWord currentWordIndex ' \(currentWordIndex)")
    wordTextField.textColor = UIColor.blackColor()
    wordTextField.text = nil
    currentRetryCount = 0
    let word = words[currentWordIndex]
    let fullNameArr : [String] = word.word.componentsSeparatedByString(" ")//make the word in separate between every space, then put it in the array
    for i in 0 ..< fullNameArr.count {
        wordsToAppend.append(fullNameArr[i])
        //print("element of wordsToAppend \(wordsToAppend[i])")
    }
    //print("fullNameArr length is \(fullNameArr.count)")
    print("curruentword in updateCurrentWord() \(word.word) filename \(word.filename) currentWordIndex \(currentWordIndex)")
    wordsToAppend.append(word.word)
    //print("In Array \(wordsToAppend[0]) array length \(wordsToAppend.count)")//swipe할때마다 갱신됨
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
    loadOpenEars()
  }
  
  func checkAnswer(input: String) {
    //print("'checkAnswer currentWordIndex' \(currentWordIndex) and words in checkAnswer \(words)")
    
    self.stopListening()
    self.stopFlashingbutton()
    let currentWord = words[currentWordIndex]
    print("'words in checkAnswer' \(words)")
    print("'checkAnswer currentWordFilname' \(currentWord.filename) currentWord \(currentWord.word) currentWordIndex \(currentWordIndex) and input \(input) 'answerCandidates' \(answerCandidates)" )
    let answerStatus = AnswerManager.checkAnswer(input, answerCandidates: answerCandidates)
    if answerStatus == .Correct {
      print("Correct")
      wordsToAppend.removeAll()
      wordTextField.textColor = App.primaryColor
      wordTextField.resignFirstResponder()
      wordTextField.text = currentWord.word
      answerIndicatorView.updateAnswerStatus(answerStatus, withIndex: currentWordIndex)
      print("or it is invoked here up correct??")
      playAudio(currentWord.filename, nextQuestionUponFinish: true)
      learningManager?.learnedWordIds.append(currentWord.id)
      SessionManager.instance.editionManager?.learnWord(learningManager!.groupId, wordId: currentWord.id)
      
    } else {
      print("Incorrect")
      currentRetryCount += 1
      if currentRetryCount < maxRetryCount {
        //buttonFlashing = false
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
        wordsToAppend.removeAll()//문장나올때 마다 갱신
        wordTextField.resignFirstResponder()
        wordTextField.textColor = App.errorColor
        wordTextField.text = currentWord.word
        answerIndicatorView.updateAnswerStatus(answerStatus, withIndex: currentWordIndex)
        //print("it is invoked here down incorrect??")//그러면 '정답이 아닙니다.' 를 보여주면 안되는데
        playAudio(currentWord.filename, nextQuestionUponFinish: true)
        SessionManager.instance.editionManager?.wrongLearningWord(learningManager!.groupId, wordId: currentWord.id)
        checkIfLearnedAllorRestudy()
        
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
          self!.stopListening()
          self!.stopFlashingbutton()
          SELF.dismissViewControllerAnimated(true, completion: nil)
        }
      }.addDisposableTo(disposeBag)
    
  }
  
  func didTapImage(recognizer: UIPanGestureRecognizer) {
    let word = words[currentWordIndex]
    playAudio(word.filename)
    
  }
  
  func playAudio(filename: String, nextQuestionUponFinish: Bool = false) {
    print("playAudio filename \(filename) currentWordIndex \(currentWordIndex)")
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
          self.stopListening()
          self.stopFlashingbutton()
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
    
    func checkIfLearnedAllorRestudy(){
        self.stopFlashingbutton()
        self.stopListening()
        if currentWordIndex + 1 < words.count {
          currentWordIndex += 1// currentWordIndex is getting increased by here, then it shows the word of the index in array.
          //print("just want to see \(currentWordIndex)")
          timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(LearningStep3ViewController.updateCurrentWord), userInfo: nil, repeats: true)
        
          //updateCurrentWord()// and this method is invoked.
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
  
  // MARK: AVAudioPlayerDelegate
//  func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
//    self.stopListening()
//    self.stopFlashingbutton()
//    
//    print("audioPlayerDidFinishPlaying currentWordIndex \(currentWordIndex) and words.count \(words.count)")
//    if currentWordIndex + 1 < words.count {
//      currentWordIndex += 1// currentWordIndex is getting increased by here, then it shows the word of the index in array.
//      print("just want to see \(currentWordIndex)")
//      updateCurrentWord()// and this method is invoked.
//    } else {
//      // check if the user finishes all
//      if learningManager!.learnedWordIds.count == learningManager!.learningWordIds.count {
//        // learn group and finish
//        
//        showLearnedDialog()
//      } else {
//        restudy()
//        
//      }
//    }
//    UIApplication.sharedApplication().endIgnoringInteractionEvents()
//  }
  
  func showLearnedDialog() {//when user passes(correct) all question, this method get invoked
    HUD.message("학습 데이터를 전송중입니다.")
    SessionManager.instance.editionManager!.learnGroup(learningManager!.groupId)
    $.wireframe.promptFor(self, title: "학습 완료", message: "\(learningManager!.groupName) 단원 학습을 완료하였습니다.", cancelAction: "끝내기", actions: [])
      .subscribeNext { _ in
        self.dismissViewControllerAnimated(true, completion: nil)
      }.addDisposableTo(disposeBag)
    HUD.hide()
    
  }
  
  func restudy() {
    print("재시험입니다!")
    
    if let learningManager = learningManager {
      let numberOfIncorrectWords = learningManager.learningWordIds.count - learningManager.learnedWordIds.count
      
      $.wireframe.promptFor(self, title: "다시 공부", message: "외우지 못한 단어가 \(numberOfIncorrectWords)개 있습니다. 다시 공부해 주세요.", cancelAction: "학습 종료", actions: ["다시 공부"])
        .subscribeNext { action in

          switch action {
          case "다시 공부":
            
            let learningWordIds = Array(learningManager.learningWordIds)
            learningManager.learningWordIds.removeAll()//learningWordIds 초기화
            for wordId in learningWordIds {
              if !learningManager.learnedWordIds.contains(wordId) {
                learningManager.learningWordIds.append(wordId)//incorrect words from speech session.
              }
            }
            learningManager.notLearnedWordIds = Array(learningManager.learningWordIds)//incorrect words from speech session.
            self.player?.delegate = nil
            self.player = nil
            if let delegate = self.restudyDelegate {
              delegate.onRestudy()
                
            }
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            //self.navigationController?.popViewControllerAnimated(true)

          case "학습 종료":
            self.dismissViewControllerAnimated(true, completion: nil)
          default:
            break
          }
        }.addDisposableTo(disposeBag)
    }
  }
    
    //OpenEars methods begin
    
    func loadOpenEars() {
        print("'loadOpenEars currentWordIndex' \(currentWordIndex)")
        self.openEarsEventsObserver = OEEventsObserver()
        self.openEarsEventsObserver.delegate = self
        
        let lmGenerator: OELanguageModelGenerator = OELanguageModelGenerator()
        
        let name = "LanguageModelFileStarSaver"
        for _ in 0..<wordsToAppend.count {
            //print("loadOpenEars \(wordsToAppend[i])")
        }
        lmGenerator.generateLanguageModelFromArray(wordsToAppend, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        
        lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
        dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
    }

    
    func startListening() {
        do {
            try OEPocketsphinxController.sharedInstance().setActive(true)
        } catch _ {
        }
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
        
        
    }
    
    func stopListening() {
        
        OEPocketsphinxController.sharedInstance().stopListening()
    }

    
    func pocketsphinxFailedNoMicPermissions() {
        
        NSLog("Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
        self.startupFailedDueToLackOfPermissions = true
        if OEPocketsphinxController.sharedInstance().isListening {
            let error = OEPocketsphinxController.sharedInstance().stopListening() // Stop listening if we are listening.
            if(error != nil) {
                NSLog("Error while stopping listening in micPermissionCheckCompleted: %@", error);
            }
        }
    }
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //self.btnRecord.setTitle("Record", forState: UIControlState.Normal)
            //self.btnPlay.enabled = true
            try audioSession.setActive(false)
        } catch {
        }
        doPlayMyVoice()
        
        print("wordTextFiledasdfasdf \(hypothesis)")
        checkAnswer(hypothesis)
        return
    }
    
    //자기 목소리 녹음
    //MARK:- Method store sound in Directory.
    
    func directoryURL() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent("sound.m4a")
        //print("soundURL: \(soundURL)")
        return soundURL
    }

    func doPlayMyVoice() {
        if !audioRecorder.recording {
            self.audioPlayer = try! AVAudioPlayer(contentsOfURL: audioRecorder.url)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = self
            self.audioPlayer.play()
        }
    }
    
    //MARK:- AudioRecordDelegate
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print(flag)
    }
    
    //MARK:- AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.stopListening()
        self.stopFlashingbutton()
        print("when this is invoked??")
        print(flag)
    }
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?){
        print(error.debugDescription)
    }
    internal func audioPlayerBeginInterruption(player: AVAudioPlayer){
        print(player.debugDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
}
