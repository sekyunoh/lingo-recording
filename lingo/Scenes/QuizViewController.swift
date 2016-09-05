//
//  ReviewViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/1/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
import XLPagerTabStrip

enum QuizSubTab: String {
  case Practice = "연습시험"
  case Exam = "출제된 시험"
}

class QuizViewController: ButtonBarPagerTabStripViewController {
  
  override func loadView() {
    super.loadView()
    view.backgroundColor = App.windowBackgroundColor
  }
  
  
  override func viewDidLoad() {
    self.navigationController?.navigationBar.translucent = false
    settings.style.buttonBarBackgroundColor = .whiteColor()
    settings.style.buttonBarItemBackgroundColor = .whiteColor()
    settings.style.selectedBarBackgroundColor = App.primaryColor
    settings.style.buttonBarItemFont = .boldSystemFontOfSize(14)
    settings.style.selectedBarHeight = 3.0
    settings.style.buttonBarMinimumLineSpacing = 0
//    settings.style.buttonBarMinimumInteritemSpacing = 0
    settings.style.buttonBarItemTitleColor = .darkGrayColor()
    settings.style.buttonBarItemsShouldFillAvailiableWidth = true
    settings.style.buttonBarLeftContentInset = 0
    settings.style.buttonBarRightContentInset = 0
    
    changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
      guard changeCurrentIndex == true else { return }
      oldCell?.label.textColor = .darkGrayColor()
      newCell?.label.textColor = App.primaryColor
      
      if animated {
        UIView.animateWithDuration(0.1, animations: { 
          newCell?.transform = CGAffineTransformMakeScale(1.0, 1.0)
          oldCell?.transform = CGAffineTransformMakeScale(0.8, 0.8)
        })
      }
      else {
        newCell?.transform = CGAffineTransformMakeScale(1.0, 1.0)
        oldCell?.transform = CGAffineTransformMakeScale(0.8, 0.8)
      }
    }
    super.viewDidLoad()
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.title = App.Title.quiz
  }
  
  override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    return [
      QuizFormViewController(),
      QuizListViewController()
    ]
  }
  
}
