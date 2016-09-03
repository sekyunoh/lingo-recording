//
//  WordTableCell.swift
//  lingo
//
//  Created by Taehyun Park on 2/16/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif

class WordTableCell: UITableViewCell {
  static let name = "WordTableCell"
  
  var wordImageView: UIImageView!
  var wordLabel: UILabel!
  var definitionLabel: UILabel!
  
  var disposeBag: DisposeBag!
  
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
    
    wordImageView = UIImageView().then{
      $0.contentMode = .ScaleToFill
    }
    addSubview(wordImageView)
    wordImageView.snp_makeConstraints {
      $0.size.equalTo(120)
      $0.top.bottom.left.equalTo(self)
    }
    
    
    wordLabel = UILabel().then {
      $0.font = UIFont.boldSystemFontOfSize(18.0)
    }
    addSubview(wordLabel)
    wordLabel.snp_makeConstraints {
      $0.left.equalTo(wordImageView.snp_right).offset(8)
      $0.top.equalTo(self).offset(16)
    }
    
    definitionLabel = UILabel().then {
      $0.font = UIFont.systemFontOfSize(16.0)
    }
    addSubview(definitionLabel)
    definitionLabel.snp_makeConstraints {
      $0.left.equalTo(wordImageView.snp_right).offset(8)
      $0.top.equalTo(wordLabel.snp_bottom).offset(8)
      $0.bottom.equalTo(self).offset(-16)
    }
    
    
  }
  
  func bindTo(word: Word) {
    disposeBag = DisposeBag()
    wordImageView.iv_setImageWithFilename(word.filename)?.addDisposableTo(disposeBag)
    wordLabel.text = word.word
    if word.form == idiom {
      definitionLabel.text = word.krDefinition
    } else {
      definitionLabel.text = "\(word.form). \(word.krDefinition)"
      
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = nil
  }
  
}
