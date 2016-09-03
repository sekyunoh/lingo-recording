//
//  ChoiceButton.swift
//  lingo
//
//  Created by Taehyun Park on 2/28/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import Material
import SnapKit

class ChoiceButton: FlatButton {
  var answerLabel: UILabel!
  
  var choice: Choiceable!
  
  let textColor = MaterialColor.grey.darken3
  let answerColor = MaterialColor.grey.darken2
  
  override func prepareView() {
    super.prepareView()
    pulseColor = MaterialColor.blue.accent3
    cornerRadiusPreset = .None
    contentEdgeInsetsPreset = .WideRectangle3
    exclusiveTouch = true
    
    answerLabel = UILabel().then {
      $0.numberOfLines = 1
      $0.font = UIFont.systemFontOfSize(14)
      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.5
      $0.textColor = self.answerColor
      $0.textAlignment = .Center
//      $0.backgroundColor = UIColor(white: 0, alpha: 0.1)
    }
    
    addSubview(answerLabel)
    
    answerLabel.snp_makeConstraints {
      $0.left.right.equalTo(self)
      $0.width.equalTo(self)
      $0.bottom.equalTo(self).offset(-2)
    }
    
    if let titleLabel = self.titleLabel {
      titleLabel.numberOfLines = 1
      titleLabel.adjustsFontSizeToFitWidth = true
      titleLabel.minimumScaleFactor = 0.5
    }
  }
  
  
  func updateChoice(choice: Choice, type: QuestionAnswerType){
    updateChoice(choice.toChoiceable(type))
  }
  
  func updateChoice(choice: Choiceable){
    self.choice = choice
    setTitleColor(textColor, forState: .Normal)
    setTitle(choice.choice, forState: .Normal)
    answerLabel.textColor = answerColor
    answerLabel.text = choice.explanation
    answerLabel.hidden = true
    layer.backgroundColor = UIColor.whiteColor().CGColor
    userInteractionEnabled = true
  }
  
  func showAnswerLabel() {
    answerLabel.hidden = false
    userInteractionEnabled = false
  }
  
  func updateChoiceStatus(answerStatus: AnswerStatus) {
    if answerStatus == .Correct {
      backgroundColor = App.primaryColor
    } else {
      backgroundColor = App.errorColor
    }
    setTitleColor(UIColor.whiteColor(), forState: .Normal)
    answerLabel.textColor = UIColor.whiteColor()

    
  }
  
  
  
}
