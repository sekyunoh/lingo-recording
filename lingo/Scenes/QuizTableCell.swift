//
//  QuizTableCell.swift
//  lingo
//
//  Created by Taehyun Park on 3/8/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
class QuizTableCell: UITableViewCell {
  
  static let id = "Quiz"
  
  var nameLabel: UILabel!
  var authorLabel: UILabel!
  var scoreLabel: UILabel!
  var statusLabel: UILabel!
  var syncImage: UIImageView!
  
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
    selectionStyle = .None
    self.separatorInset = UIEdgeInsetsZero
    initSubViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  private func initSubViews() {
    nameLabel = UILabel().then {
      $0.font = UIFont.boldSystemFontOfSize(18)
    }
    addSubview(nameLabel)
    nameLabel.snp_makeConstraints {
      $0.top.left.equalTo(self).offset(16)
    }
    
    syncImage = UIImageView().then {
      $0.contentMode = .ScaleAspectFit
      $0.image = UIImage(named: "alert-circle")
    }
    
    addSubview(syncImage)
    syncImage.snp_makeConstraints {
      $0.left.equalTo(nameLabel.snp_right).offset(4)
      $0.centerY.equalTo(nameLabel)
      $0.size.equalTo(16)
    }
    
    authorLabel = UILabel().then {
      $0.font = UIFont.systemFontOfSize(14)
    }
    addSubview(authorLabel)
    authorLabel.snp_makeConstraints {
      $0.left.equalTo(self).offset(16)
      $0.bottom.equalTo(self).offset(-16)
      $0.top.greaterThanOrEqualTo(nameLabel).offset(8)
    }
    
    
    scoreLabel = UILabel().then {
      $0.font = UIFont.systemFontOfSize(18)
      $0.textColor = UIColor.orangeColor()
    }
    addSubview(scoreLabel)
    scoreLabel.snp_makeConstraints {
      $0.top.equalTo(self).offset(16)
      $0.right.equalTo(self).offset(-16)
    }
    
    statusLabel = UILabel().then {
      $0.font = UIFont.systemFontOfSize(14)
    }
    addSubview(statusLabel)
    statusLabel.snp_makeConstraints {
      $0.right.equalTo(self).offset(-16)
      $0.bottom.equalTo(self).offset(-16)
    }
    
  }
  
  func bindTo(quiz: Quiz) {
    syncImage.hidden = true
    nameLabel.text = quiz.name
    authorLabel.text = quiz.authorName + " 선생님"
    if quiz.status == QuizStatus.Solved.rawValue {
      statusLabel.text = "응시 완료"
      scoreLabel.text = String(format:" %.1f", quiz.score)
      scoreLabel.textColor = UIColor.orangeColor()
      if quiz.sync != SyncStatus.Synchronized.rawValue {
        syncImage.hidden = false
      }
    } else {
      
      let currentTime = NSDate()
      if (quiz.startDate > currentTime) {
        statusLabel.textColor = UIColor.greenColor()
        statusLabel.text = "\(quiz.startDate.timespan) 응시 가능"
      } else if(quiz.dueDate > currentTime) {
        statusLabel.textColor = UIColor.greenColor()
        statusLabel.text = "\(quiz.dueDate.timespan) 응시 마감"
      } else {
        statusLabel.textColor = App.errorColor
        statusLabel.text = "응시 마감됨"
      }
      scoreLabel.text = "--"
      
    }
  }
  
}
