//
//  FlashcardsViewModel.swift
//  lingo
//
//  Created by Taehyun Park on 2/16/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
#if !RX_NO_MODULE
  import RxSwift
  import RxCocoa
#endif

class FlashcardsViewModel: NSObject {
  
  let editionId: Int

  let flashcardsSection: DefaultsKey<Int>
  let flashcardsRow: DefaultsKey<Int>
  
  let indexPath: Variable<NSIndexPath>
  
  let indexPathDriver: Driver<NSIndexPath>
  
  
  
  init(editionManager: EditionManager) {
    editionId = editionManager.editionId
    flashcardsSection = editionManager.flashcardsSection
    flashcardsRow = editionManager.flashcardsRow
    indexPath = Variable(NSIndexPath(forRow: (Defaults[flashcardsRow]), inSection: (Defaults[flashcardsSection])))
    indexPathDriver = indexPath.asDriver().distinctUntilChanged()
  }
  

}