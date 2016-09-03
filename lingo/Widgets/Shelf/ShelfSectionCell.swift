//
//  ShelfSectionCell.swift
//  lingo
//
//  Created by Taehyun Park on 2/8/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit

class ShelfSectionCell: UITableViewCell {
  static let shelfSectionCell = "SectionCell"
  
  var titleLabel: UILabel!
  var collectionView: UICollectionView!
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
    selectionStyle = .None
    self.separatorInset = UIEdgeInsetsZero
    initSubViews()
  }
  

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func initSubViews() {
    titleLabel = UILabel()
    addSubview(titleLabel)
    titleLabel.snp_makeConstraints {
      $0.width.equalTo(self)
    }
    

    collectionView = UICollectionView().then {
      $0.clipsToBounds = false
      $0.backgroundColor = UIColor.whiteColor()
      $0.showsHorizontalScrollIndicator = false
      $0.showsVerticalScrollIndicator = false
      $0.registerClass(ShelfSectionCell.self, forCellWithReuseIdentifier: ShelfSectionCell.shelfSectionCell)
    }
    addSubview(collectionView)
    collectionView.snp_makeConstraints {
      $0.width.equalTo(self)
      $0.height.equalTo(ShelfItemCell.height)
      $0.top.equalTo(titleLabel.snp_bottom).offset(4)
    }
    
  }
  
  
}
