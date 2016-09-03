//
//  LearningProgressView.swift
//  lingo
//
//  Created by Taehyun Park on 2/7/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit

class LearningProgressView: UIView {
  
  var tableView: UITableView!
  
  convenience init() {
    self.init(frame: UIScreen.mainScreen().bounds)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func initUI() {
    self.backgroundColor = App.windowBackgroundColor
    tableView = UITableView().then {
      $0.rowHeight = 72
      $0.tableFooterView = UIView()
      $0.separatorInset = UIEdgeInsetsZero
      $0.alwaysBounceHorizontal = false
      $0.alwaysBounceVertical = false
      if #available(iOS 9, *) {
        $0.cellLayoutMarginsFollowReadableWidth = false
      }
      $0.layoutMargins = UIEdgeInsetsZero
      $0.setEditing(false, animated: false)
      $0.registerClass(PublishedGroupTableCell.self, forCellReuseIdentifier: PublishedGroupTableCell.name)
    }
    addSubview(tableView)
    tableView.snp_makeConstraints {
      $0.size.equalTo(self)
//      $0.top.left.right.equalTo(self)
//      $0.top.equalTo(globalNavigationBarHeight)
//      $0.bottom.equalTo(self).offset(-globalTabbarHeight)
    }
  }
  
}
