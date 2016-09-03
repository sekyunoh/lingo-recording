//
//  SideBarTableCell.swift
//  lingo
//
//  Created by Taehyun Park on 2/16/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import Material

class SideBarTableCell: UITableViewCell {

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
    selectionStyle = .None
    initSubViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initSubViews() {
    selectionStyle = .None
    textLabel!.textColor = MaterialColor.white
    textLabel!.font = RobotoFont.medium
    imageView!.tintColor = MaterialColor.cyan.lighten4
  }
}
