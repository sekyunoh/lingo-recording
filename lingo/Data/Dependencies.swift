//
//  Dependencies.swift
//  lingo
//
//  Created by Taehyun Park on 1/4/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import RxSwift

class Dependencies {
  static let instance = Dependencies()
  
  let URLSession = NSURLSession.sharedSession()
  let backgroundWorkScheduler : ImmediateSchedulerType
  let zipScheduler: ImmediateSchedulerType
  let mainScheduler : SerialDispatchQueueScheduler
  
  let wireframe: DefaultWireframe
  
  private init() {
    wireframe = DefaultWireframe()
    let operationQueue = NSOperationQueue()
    operationQueue.maxConcurrentOperationCount = 4
    operationQueue.qualityOfService = NSQualityOfService.UserInitiated
    backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    let singleQueue = NSOperationQueue()
    singleQueue.maxConcurrentOperationCount = 1
    singleQueue.qualityOfService = .Background
    zipScheduler = OperationQueueScheduler(operationQueue: singleQueue)
    mainScheduler = MainScheduler.instance
  }
}