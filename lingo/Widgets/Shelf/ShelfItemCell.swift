//
//  ShelfItemCell.swift
//  lingo
//
//  Created by Taehyun Park on 2/8/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit

public class ShelfItemCell: UICollectionViewCell {
  
  static let shelfItemCell = "ItemCell"
  
  static let width = 100
  static let height = 130
  
  var imageView: UIImageView!
  var titleLabel: UILabel!
  
  init() {
    super.init(frame: CGRect(x: 0, y: 0, width: ShelfItemCell.width, height: ShelfItemCell.height))
    initSubViews()
  }
  
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  private func initSubViews() {
    imageView = UIImageView().then {
      $0.contentMode = .ScaleAspectFit
      $0.layer.cornerRadius = 20
    }
    addSubview(imageView)
    imageView.snp_makeConstraints {
      $0.size.equalTo(ShelfItemCell.width)
      $0.left.top.equalTo(self)
    }
    
    titleLabel = UILabel()
    addSubview(titleLabel)
    titleLabel.snp_makeConstraints {
      $0.top.equalTo(imageView.snp_bottom).offset(4)
    }
  }
    
}
