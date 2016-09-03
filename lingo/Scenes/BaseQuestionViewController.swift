//
//  BaseQuestionViewController.swift
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

class BaseQuestionViewController: ViewController {
  
  
  let question: Question
  let questionType: QuestionType
  var upperCardView: UIView!
  var answerStatusView: UIImageView!
  
  var realm: Realm!
  
  var questionImageView: UIImageView?
  var questionLabel: UILabel?
  
  
  var examViewController: ExamViewController {
    return parentViewController as! ExamViewController
  }
  
  required init(question: Question) {
    self.question = question
    self.questionType = QuestionType.type(question.type)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    upperCardView = UIView().then {
      $0.layer.shadowColor = UIColor.blackColor().CGColor
      $0.layer.shadowOpacity = 0.25
      $0.layer.shadowOffset = CGSizeMake(0, 1.5)
      $0.layer.shadowRadius = 4.0
      $0.layer.shouldRasterize = true
      $0.layer.rasterizationScale = UIScreen.mainScreen().scale
      $0.layer.cornerRadius = 10.0;
      $0.backgroundColor = UIColor.whiteColor()
    }
    view.addSubview(upperCardView)
    let size = min(view.frame.size.width - 40, (view.frame.size.height - 40) / 2)
    upperCardView.snp_makeConstraints {
      $0.top.equalTo(view).offset(20)
      $0.centerX.equalTo(view)
      $0.size.equalTo(size)
    }
    
    
    if questionType.displayImage {
      questionImageView = UIImageView().then {
        $0.contentMode = .ScaleAspectFit
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
      }
      upperCardView.addSubview(questionImageView!)
      questionImageView?.snp_makeConstraints {
        $0.edges.equalTo(upperCardView)
      }
    }
    
    if questionType.displayQuestion {
      questionLabel = UILabel().then {
        $0.minimumScaleFactor = 0.5
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .Center
        $0.font = UIFont.boldSystemFontOfSize(20)
      }
      view.addSubview(questionLabel!)
    }
    
    if let questionLabel = questionLabel where questionType.displayImage {
      questionLabel.layer.masksToBounds = true
      questionLabel.clipsToBounds = true
      questionLabel.backgroundColor = UIColor.init(white: 0, alpha: 1)
      questionLabel.textColor = UIColor.whiteColor()
      questionLabel.snp_makeConstraints {
        $0.left.right.equalTo(upperCardView)
        $0.height.equalTo(40)
        $0.bottom.equalTo(upperCardView).offset(8)
      }
    } else {
      questionLabel?.snp_makeConstraints {
        $0.width.left.right.equalTo(upperCardView)
        $0.centerY.equalTo(upperCardView)
      }
    }
    
    answerStatusView = UIImageView().then {
      $0.contentMode = .Center
    }
    
    upperCardView.addSubview(answerStatusView)
    answerStatusView.snp_makeConstraints {
      $0.edges.equalTo(upperCardView).inset(UIEdgeInsetsMake(20, 20, 20, 20))
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    realm = try! Realm()
    setupQuestion()
    if question.solved == nil {
      toggleInputs(true)
    } else {
      toggleInputs(false)
      displayResult()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setupQuestion() {
    questionImageView?.iv_setImageWithFilename(question.file)?.addDisposableTo(disposeBag)
    questionLabel?.text = question.question
  }
  
  func toggleInputs(enabled: Bool) {
    
  }
  
  func displayResult() {
    
  }
}
