//
//  AnswerIndicatorView.swift
//  lingo
//
//  Created by Taehyun Park on 3/3/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import XCGLogger

enum AnswerStatus: Int {
  case NotSolved = 0,
  Correct,
  Incorrect,
  Timeout
  
  static func ordinal(position: Int) -> AnswerStatus {
    switch position {
    case 0:
      return .NotSolved
    case 1:
      return .Correct
    case 2:
      return .Incorrect
    default:
      return .Timeout
    }
  }
  
  static var values: [AnswerStatus] {
    return [.NotSolved, .Correct, .Incorrect, Timeout]
  }
}

class AnswerIndicatorCell: UICollectionViewCell {
  var imageView: UIImageView!
  
  let log = XCGLogger.defaultInstance()
  override init(frame: CGRect) {
    super.init(frame: frame)
    imageView = UIImageView().then {
      $0.contentMode = .ScaleToFill
      $0.userInteractionEnabled = false
      $0.layer.cornerRadius = (frame.size.width - 4) / 2
      $0.layer.masksToBounds = true
      $0.layer.borderColor = App.primaryColor.CGColor
      $0.layer.borderWidth = 2
    }
    addSubview(imageView)
    imageView.snp_makeConstraints {
      $0.edges.equalTo(self).inset(2)
    }
    layer.cornerRadius = frame.size.width / 2
    layer.borderWidth = 2
    //    layer.borderColor = UIColor.redColor().CGColor
    //    layer.borderWidth = 1
    
    // Corner Radius
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func bindTo(answerStatus: AnswerStatus, selected: Bool) {
    switch answerStatus {
      
    case .NotSolved:
      imageView.backgroundColor = UIColor.transparent()
      if selected {
        imageView.layer.borderColor = UIColor.transparent().CGColor
        layer.borderColor = App.primaryColor.CGColor
      } else {
        layer.borderColor = UIColor.transparent().CGColor
        imageView.layer.borderColor = App.primaryColor.CGColor
      }
    case .Correct:
      imageView.backgroundColor = App.primaryColor
      if selected {
        imageView.layer.borderColor = App.primaryColor.CGColor
        layer.borderColor = App.primaryColor.CGColor
      } else {
        layer.borderColor = UIColor.transparent().CGColor
        imageView.layer.borderColor = App.primaryColor.CGColor
      }
    default:
      imageView.backgroundColor = App.errorColor
      if selected {
        imageView.layer.borderColor = App.errorColor.CGColor
        layer.borderColor = App.errorColor.CGColor
      } else {
        layer.borderColor = UIColor.transparent().CGColor
        imageView.layer.borderColor = App.errorColor.CGColor
      }
    }
    
  }
  
}

class AnswerIndicatorView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
  static let id = "AnswerIndicator"
  let log = XCGLogger.defaultInstance()
  
  private var answerStatuses: [AnswerStatus]
  let sideInset: CGFloat
  
  var currentIndex = 0
  
  init(frame: CGRect, withQuestions numberOfQuestions: Int) {
    let flowLayout = UICollectionViewFlowLayout().then {
      $0.scrollDirection = .Horizontal
      $0.minimumInteritemSpacing = 0
      $0.minimumLineSpacing = 0
      $0.itemSize = CGSize(width: frame.size.height, height: frame.size.height)
    }
    var statuses = [AnswerStatus]()
    for _ in 1...numberOfQuestions {
      statuses.append(.NotSolved)
    }
    self.answerStatuses = statuses
    let possibleSideInset = (frame.size.width - (frame.size.height) * CGFloat(numberOfQuestions) ) / 2
    self.sideInset = possibleSideInset > 8 ? possibleSideInset : 8
    super.init(frame: frame, collectionViewLayout: flowLayout)
    showsHorizontalScrollIndicator = false
    backgroundColor = UIColor.transparent()
    registerClass(AnswerIndicatorCell.self, forCellWithReuseIdentifier: AnswerIndicatorView.id)
    delegate = self
    dataSource = self
    
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UICollectionViewDelegateFlowLayut
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(collectionView.frame.size.height, collectionView.frame.size.height)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, sideInset, 0, sideInset)
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
  }
  
  // MARK: - UICollectionViewDataSource
  
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return answerStatuses.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AnswerIndicatorView.id, forIndexPath: indexPath) as? AnswerIndicatorCell else {
      fatalError("UICollectionViewCell should be or extend from ButtonBarViewCell")
    }
    cell.bindTo(answerStatuses[indexPath.row], selected: indexPath.row == currentIndex)
    return cell
  }
  
  func updateAnswerStatuses(answerStatuses: [AnswerStatus]) {
    if self.answerStatuses.count == answerStatuses.count {
      self.answerStatuses = answerStatuses
      reloadData()
      collectionViewLayout.invalidateLayout()
    }
  }
  
  func updateAnswerStatus(answerStatus: AnswerStatus, withIndex index: Int) {
    if index < answerStatuses.count {
      answerStatuses[index] = answerStatus
    }
    reloadData()
    collectionViewLayout.invalidateLayout()
  }
  
  func moveCurrentIndex(index: Int) {
    if currentIndex != index {
      currentIndex = index
      reloadData()
      scrollToItemAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), atScrollPosition: .Left, animated: true)
      collectionViewLayout.invalidateLayout()
    }
  }
  
}
