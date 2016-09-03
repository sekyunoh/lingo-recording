//
//  LearningGroupTableCell.swift
//  lingo
//
//  Created by Taehyun Park on 2/15/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit
import XCGLogger
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif

class PublishedGroupTableCell: UITableViewCell {
  
  static let name = "PublishedGroupCell"
  
  var learnedGroupImage: UIImageView!
  var titleLabel: UILabel!
  var learnedWordsLabel: UILabel!
  var totalWordsLabel: UILabel!
  
  
  
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
    learnedGroupImage = UIImageView().then {
      $0.contentMode = .ScaleAspectFit
      $0.image = UIImage(named: "learned_group")
    }
    addSubview(learnedGroupImage)
    learnedGroupImage.snp_makeConstraints {
      $0.size.equalTo(48)
      $0.left.equalTo(self)
//      $0.left.equalTo(self).offset(8)
      $0.centerY.equalTo(self)
    }
    
    totalWordsLabel = UILabel().then {
      $0.font = UIFont.boldSystemFontOfSize(14.0)
    }
    addSubview(totalWordsLabel)
    totalWordsLabel.snp_makeConstraints {
      $0.right.equalTo(self).offset(-8)
      $0.centerY.equalTo(self)
    }
    
    learnedWordsLabel = UILabel().then {
      $0.font = UIFont.boldSystemFontOfSize(14.0)
      $0.textColor = UIColor.orangeColor()
    }
    addSubview(learnedWordsLabel)
    learnedWordsLabel.snp_makeConstraints {
      $0.right.equalTo(totalWordsLabel.snp_left).offset(-8)
      $0.centerY.equalTo(self)
    }
    
    
    
    titleLabel = UILabel().then {
      $0.font = UIFont.systemFontOfSize(18.0)
    }
    addSubview(titleLabel)
    
    titleLabel.snp_makeConstraints {
      $0.left.equalTo(learnedGroupImage.snp_right)
      $0.right.lessThanOrEqualTo(learnedWordsLabel.snp_left).offset(-8)
      $0.centerY.equalTo(self)
    }
  }
  
  func bindPublishedGroup(publishedGroup: PublishedGroup, withLearnedGroup learnedGroup: LearnedGroup?, withNumberOfLearnedWords learnedWords: Int) {
    
    titleLabel.text = publishedGroup.name
    totalWordsLabel.text = "\(publishedGroup.numberOfWords)"
    var isLearnedGroup = false
    if let learnedGroup = learnedGroup {
      isLearnedGroup =  learnedGroup.learnedCount > 0
    }
    learnedWordsLabel.text = "\(learnedWords)"
    learnedGroupImage.hidden = !isLearnedGroup
  }
  
  
  
}
