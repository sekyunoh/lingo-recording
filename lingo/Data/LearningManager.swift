//
//  LearningManager.swift
//  lingo
//
//  Created by Taehyun Park on 2/7/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import XCGLogger

protocol RestudyDelegate {
  func onRestudy()
}

class LearningManager: NSObject {
  var notLearnedWordIds: [Int]
  let groupName: String
  let groupId: Int
  let keepOrder: Bool
  
  var learningWordIds = [Int]()
  var learnedWordIds = [Int]()
  
  init(groupId: Int, name: String, keepOrder: Bool, notLearnedWordIds: [Int]) {
    XCGLogger.defaultInstance().debug("groupId=\(groupId) name=\(name) keepOrder=\(keepOrder) notLearnedWordIds=\(notLearnedWordIds)")
    self.groupId = groupId
    self.groupName = name
    self.keepOrder = keepOrder
    self.notLearnedWordIds = notLearnedWordIds
    self.learningWordIds = Array(notLearnedWordIds)
  }
}