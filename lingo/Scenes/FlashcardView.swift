//
//  FlashcardView.swift
//  lingo
//
//  Created by Taehyun Park on 2/15/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
#if !RX_NO_MODULE
  import RxSwift
#endif

class FlashcardView: UIView {
  var debugLabel: UILabel?
  var containerView: UIView!
  var wordImageView: UIImageView!
  var starView: UIImageView!
  var wordLabel: UILabel!
  var definitionHeader: UILabel!
  var definitionLabel: UILabel!
  var exampleHeader: UILabel!
  var exampleLabel: UILabel!
  
  var loadImageDisposable: Disposable?
  
  var word: Word!
  var indexPath: NSIndexPath!
  var starred = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func initUI() {
    // Shadow
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOpacity = 0.25
    layer.shadowOffset = CGSizeMake(0, 1.5)
    layer.shadowRadius = 4.0
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.mainScreen().scale
    //    layer.borderColor = UIColor.redColor().CGColor
    //    layer.borderWidth = 1
    
    // Corner Radius
    layer.cornerRadius = 10.0;
    
    backgroundColor = UIColor.whiteColor()
    
    containerView = UIView(frame: frame).then {
      $0.layer.cornerRadius = 10.0;
      $0.clipsToBounds = true
    }
    addSubview(containerView)
    
    wordImageView = UIImageView(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.width))).then {
      $0.contentMode = .ScaleToFill
    }
    containerView.addSubview(wordImageView)
    
    starView = UIImageView(frame: CGRect(x: frame.origin.x, y: 0, width: 48, height: 48))
    containerView.addSubview(starView)
    wordLabel = UILabel().then {
      $0.font = UIFont.boldSystemFontOfSize(26.0)
      $0.numberOfLines = 0
      $0.adjustsFontSizeToFitWidth = false
      $0.lineBreakMode = .ByWordWrapping
    }
    containerView.addSubview(wordLabel)
    wordLabel.snp_makeConstraints {
      $0.left.equalTo(wordImageView).offset(8)
      $0.right.equalTo(wordImageView).offset(-8)
      $0.top.equalTo(wordImageView.snp_bottom).offset(8)
    }
    //
    
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
      $0.top.equalTo(wordLabel.snp_bottom).offset(8)
      $0.size.equalTo(28)
    }
    
    definitionLabel = UILabel().then {
      $0.font = UIFont.systemFontOfSize(18.0)
      $0.numberOfLines = 2
      $0.adjustsFontSizeToFitWidth = true
      $0.lineBreakMode = .ByClipping
      //      $0.backgroundColor = UIColor.lightGrayColor()
    }
    containerView.addSubview(definitionLabel)
    definitionLabel.snp_makeConstraints {
      $0.left.equalTo(definitionHeader.snp_right).offset(8)
      $0.right.equalTo(wordImageView).offset(-8)
      $0.top.equalTo(definitionHeader).offset(4)
    }
    
    exampleHeader = UILabel().then {
      $0.font = UIFont.boldSystemFontOfSize(18.0)
      $0.backgroundColor = UIColor.holoPurple()
      $0.textColor = UIColor.whiteColor()
      $0.text = "예"
      $0.textAlignment = .Center
    }
    
    containerView.addSubview(exampleHeader)
    
    exampleHeader.snp_makeConstraints {
      $0.left.equalTo(wordImageView)
      $0.top.greaterThanOrEqualTo(definitionLabel.snp_bottom)
      $0.top.greaterThanOrEqualTo(wordLabel.snp_bottom)
      $0.size.equalTo(28)
    }
    
    exampleLabel = UILabel().then {
      $0.font = UIFont.systemFontOfSize(18.0)
      $0.numberOfLines = 3
      $0.lineBreakMode = .ByClipping
      $0.textColor = UIColor.holoPurple()
      $0.adjustsFontSizeToFitWidth = true
      //      $0.backgroundColor = UIColor.lightGrayColor()
    }
    containerView.addSubview(exampleLabel)
    exampleLabel.snp_makeConstraints {
      $0.left.equalTo(exampleHeader.snp_right).offset(8)
      $0.right.equalTo(wordImageView).offset(-8)
      $0.top.equalTo(exampleHeader).offset(4)
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
  
  func bindTo(indexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0), word: Word, starred: Bool) {
    self.indexPath = indexPath
    loadImageDisposable = wordImageView.iv_setImageWithFilename(word.filename)
    wordLabel.text = word.word
    if word.form == idiom {
      definitionLabel.text = word.krDefinition
      exampleHeader.hidden = true
      exampleLabel.hidden = true
    } else {
      definitionLabel.text = "\(word.form). \(word.krDefinition)"
      exampleLabel.text = word.example
      exampleHeader.hidden = false
      exampleLabel.hidden = false
      
    }
    updateStarred(starred)
    self.word = word
    debugLabel?.text = "\(word.id)"
    
  }
  
  func updateStarred(starred: Bool) {
    self.starred = starred
    if starred  {
      starView.image = UIImage(named: "star")
    } else {
      starView.image = UIImage(named: "star-outline")
    }
    
  }
  
  
  deinit {
    if let disposable = loadImageDisposable {
      disposable.dispose()
    }
  }
}
