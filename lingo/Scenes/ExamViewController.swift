//
//  ExamViewController.swift
//  lingo
//
//  Created by Taehyun Park on 3/7/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif
import KAProgressLabel
import AVFoundation

class ExamViewController: ViewController, AVAudioPlayerDelegate, UIScrollViewDelegate {
  let numberOfVisiblePages = 1
  
  let quizId: Int
  let numberOfQuestions: Int
  
  var realm: Realm!
  var quiz: Quiz!
  var time = 60
  
  var scrollView: UIScrollView!
  var answerIndicatorView: AnswerIndicatorView!
  var timerProgress: KAProgressLabel!
  var rightBarButtonItem: UIBarButtonItem!
  
  var questions: Results<Question>!
  var questionViewControllers: [BaseQuestionViewController?] = []
  
  var timerDisposable: Disposable?
  
  var player: AVAudioPlayer?
  
  init(quizId: Int, numberOfQuestions: Int) {
    self.quizId = quizId
    self.numberOfQuestions = numberOfQuestions
    for _ in 0..<numberOfQuestions {
      questionViewControllers.append(nil)
    }
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    scrollView = UIScrollView(frame: view.bounds).then {
      $0.pagingEnabled = true
      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false
      
      $0.alwaysBounceHorizontal = true
      $0.alwaysBounceVertical = false
      $0.scrollsToTop = false
      $0.scrollEnabled = false
    }
    view.addSubview(scrollView)
    scrollView.snp_makeConstraints {
      $0.top.left.right.bottom.equalTo(view)
      $0.width.height.equalTo(view)
    }
    let pageWidth = scrollView.frame.size.width
    scrollView.contentSize = CGSizeMake(pageWidth * CGFloat(numberOfQuestions), 1)
    let answerIndicatorViewHeight = CGFloat(16)
    answerIndicatorView = AnswerIndicatorView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: answerIndicatorViewHeight), withQuestions: numberOfQuestions)
    view.addSubview(answerIndicatorView)
    answerIndicatorView.snp_makeConstraints {
      $0.bottom.equalTo(view).offset(-2)
      $0.left.right.equalTo(view)
      $0.height.equalTo(16)
    }
    timerProgress = KAProgressLabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40)).then {
      $0.fillColor = App.primaryColor
      $0.progressColor = UIColor.whiteColor()
      $0.trackColor = UIColor.init(white: 1, alpha: 0.3)
      $0.textAlignment = .Center
      $0.userInteractionEnabled = false
      $0.startDegree = 0
      $0.endDegree = 360
      $0.progress = 0
      $0.trackWidth = 5
      $0.progressWidth = 5
      $0.textColor = UIColor.whiteColor()
      $0.font = UIFont.systemFontOfSize(16)
      $0.text = "--"
    }
    //
    //    timerProgress.labelVCBlock = { label in
    //      let currentTime = Int(60 * label.progress)
    //      label.text = "\(currentTime)"
    //    }
    rightBarButtonItem = UIBarButtonItem(customView: timerProgress)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.translucent = false
    realm = try! Realm()
    guard let quiz = realm.objectForPrimaryKey(Quiz.self, key: quizId) else {
      HUD.error()
      return
    }
    self.quiz = quiz
    questions = quiz.questions.sorted("number")
    self.title = quiz.name
    
    // Do any additional setup after loading the view.
    scrollView.delegate = self
    HUD.hide()
    if quiz.status != QuizStatus.Solved.rawValue {
      $.wireframe.promptFor(self, title: "시험 시작", message: "이름: \(quiz.name)\n문제: \(numberOfQuestions)개", cancelAction: nil, actions: ["시작하기"]).subscribeNext { _ in
        self.startQuiz()
        }.addDisposableTo(disposeBag)
    } else {
      if quiz.sync != SyncStatus.Synchronized.rawValue {
        submitQuiz(false)
      }
      
      Dispatcher.worker {
        let realm = try! Realm()
        let quiz = realm.objectForPrimaryKey(Quiz.self, key: self.quizId)
        let answerStatuses = quiz?.questions.sorted("number").map {
          return AnswerStatus.ordinal($0.status)
        }
        Dispatcher.main {
          self.answerIndicatorView.updateAnswerStatuses(answerStatuses!)
          self.scrollView.scrollEnabled = true
          
          self.loadVisiblePages()
          self.updateCurrentQuestion()
        }
        
      }
    }
    
    
    
    
  }
  
  private func startQuiz() {
    if quiz.status != QuizStatus.InProgress.rawValue {
      try! realm.write {
        quiz.status = QuizStatus.InProgress.rawValue
      }
    }
    var startingQuestion = 0
    for index in 0..<questions.count {
      let question = questions[index]
      if question.solved != nil {
        answerIndicatorView.updateAnswerStatus(AnswerStatus.ordinal(question.status), withIndex: index)
        startingQuestion = index + 1
      } else {
        break
      }
    }
    if startingQuestion < quiz.questions.count {
      answerIndicatorView.moveCurrentIndex(startingQuestion)
      scrollView.setContentOffset(CGPointMake(pageOffsetForChildIndex(index: startingQuestion), 0), animated: false)
    }
    if quiz.status != QuizStatus.Solved.rawValue {
      
    }
    loadVisiblePages()
    updateCurrentQuestion()
  }
  
  private func updateCurrentQuestion() {
    let question = questions[page]
    log.debug("page=\(self.page) currentQuestion=\(question)")
    //    time = question.time
    time = 10
    self.timerProgress.progress = 0
    timerDisposable?.dispose()
    if question.solved == nil {
      timerDisposable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .subscribe(onNext: {
          let tick = $0
          let progress = CGFloat(Float(tick+1) / Float(self.time))
          self.timerProgress.setProgress(progress, timing: TPPropertyAnimationTimingLinear, duration: 1.0, delay: 0)
          self.timerProgress.text = "\(self.time-tick)"
          if tick == self.time {
            if let questionViewController = self.questionViewControllers[self.page] where questionViewController.question.solved == nil {
              questionViewController.displayResult()
            }
            self.timerDisposable?.dispose()
          }
          
          }, onDisposed: {
            self.timerDisposable = nil
            self.timerProgress.progress = 0
        })
      disposeBag.addDisposable(timerDisposable!)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    log.debug("viewWillAppear")
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "끝내기", style: .Plain, target: self, action: "didTapBack:")
    navigationItem.rightBarButtonItem = rightBarButtonItem
  }
  
  
  func didTapBack(sender: UIBarButtonItem) {
    if quiz.status != QuizStatus.Solved.rawValue {
      $.wireframe.promptFor(self, title: "시험 종료", message:"시험을 종료하시겠습니까? 온라인 시험을 종료시에 오답처리됩니다.", cancelAction: "취소", actions: ["종료"])
        .subscribeNext { [weak self] action in
          guard let SELF = self else {
            return
          }
          if action == "종료" {
            SELF.timerDisposable?.dispose()
            SELF.dismissViewControllerAnimated(true, completion: nil)
          }
        }.addDisposableTo(disposeBag)
    } else {
      dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  
  // MARK: Pager
  
  func loadPage(page: Int) {
    if page < 0 || page >= numberOfQuestions {
      // If it's outside the range of what you have to display, then do nothing
      return
    }
    
    // 1
    if questionViewControllers[page] == nil {
      let question = questions[page]
      let questionViewController = QuestionType.type(question.type).toViewController(question)
      // 2
      var frame = scrollView.bounds
      frame.origin.x = frame.size.width * CGFloat(page)
      frame.origin.y = 0.0
      
      // 3
      addChildViewController(questionViewController)
      questionViewController.view.frame = frame
      scrollView.addSubview(questionViewController.view)
      questionViewController.didMoveToParentViewController(self)
      // 4
      questionViewControllers[page] = questionViewController
    }
  }
  
  func purgePage(page: Int) {
    if page < 0 || page >= numberOfQuestions {
      // If it's outside the range of what you have to display, then do nothing
      return
    }
    
    // Remove a page from the scroll view and reset the container array
    if let questionViewController = questionViewControllers[page] {
      questionViewController.view.removeFromSuperview()
      questionViewController.removeFromParentViewController()
      questionViewControllers[page] = nil
    }
    
  }
  
  var page: Int {
    let pageWidth = scrollView.frame.size.width
    return Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
  }
  
  func pageOffsetForChildIndex(index index: Int) -> CGFloat {
    return CGFloat(index) * CGRectGetWidth(scrollView.bounds)
  }
  
  func loadVisiblePages() {
    let page = self.page
    // Update the page control
    answerIndicatorView.moveCurrentIndex(page)
    
    // Work out which pages you want to load
    let firstPage = page - numberOfVisiblePages
    let lastPage = page + numberOfVisiblePages
    
    
    // Purge anything before the first page
    for var index = 0; index < firstPage; ++index {
      purgePage(index)
    }
    
    // Load pages in our range
    for var index = firstPage; index <= lastPage; ++index {
      loadPage(index)
    }
    
    // Purge anything after the last page
    for var index = lastPage+1; index < numberOfQuestions; ++index {
      purgePage(index)
    }
  }
  
  
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if self.scrollView == scrollView {
      // Load the pages that are now on screen
      loadVisiblePages()
    }
  }
  
  func stopTimer() {
    timerDisposable?.dispose()
  }
  
  func updateAnswerStatus(answerStatus: AnswerStatus) {
    answerIndicatorView.updateAnswerStatus(answerStatus, withIndex: page)
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
    let nextPage = page + 1
    if nextPage < numberOfQuestions {
      answerIndicatorView.moveCurrentIndex(nextPage)
      scrollView.setContentOffset(CGPointMake(pageOffsetForChildIndex(index: nextPage), 0), animated: true)
      UIApplication.sharedApplication().endIgnoringInteractionEvents()
      updateCurrentQuestion()
    } else {
      let score = Double(questions.reduce(0, combine: { (count: Int, question: Question) -> Int in
        return count + question.status == AnswerStatus.Correct.rawValue ? 1 : 0
      })) / Double(questions.count) * 100
      try! realm.write {
        quiz.score = score
        quiz.status = QuizStatus.Solved.rawValue
      }
      if !quiz.mock {
        submitQuiz(true)
      }else {
        showEndDialog()
      }
    }
  }
  
  func submitQuiz(displayEndDialog: Bool) {
    HUD.message("시험을 서버에 전송중입니다.")
    API.instance.submitQuiz(quiz.id, form: quiz.form())
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { response in
        if response.status == 200 {
          try! self.realm.write {
            self.quiz.sync = SyncStatus.Synchronized.rawValue
          }
          HUD.success()
          if displayEndDialog {
            self.showEndDialog()
          }
        } else {
          self.retryDialog()
        }
        }, onError: { error in
          self.retryDialog()
          self.log.error("failed to submit error=\(error)")
      })
      .addDisposableTo(disposeBag)
  }
  
  func showEndDialog() {

    scrollView.scrollEnabled = true
    $.wireframe.promptFor(self, title: "단어 시험 종료", message: "시험을 모두 끝냈습니다.\n점수: \(quiz.score)", cancelAction: "끝내기", actions: ["결과 확인"]).subscribeNext {
      if $0 == "끝내기" {
        self.dismissViewControllerAnimated(true, completion: nil)
      }
      }.addDisposableTo(disposeBag)
    UIApplication.sharedApplication().endIgnoringInteractionEvents()
  }
  
  func retryDialog() {
    HUD.error()
    $.wireframe.promptFor(self, title: "시험 전송 실패", message: "시험 결과 전송을 실패하였습니다.", cancelAction: "다음에", actions: ["재시도"]).subscribeNext {
      if $0 == "재시도" {
        self.submitQuiz(false)
      }
      }.addDisposableTo(disposeBag)
    
  }
  
}
