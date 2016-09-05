//
//  MainTabBarController.swift
//  lingo
//
//  Created by Taehyun Park on 2/1/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import Material
import RealmSwift
#if !RX_NO_MODULE
  import RxSwift
#endif


class MainTabBarController: UITabBarController {
  let centerButtonIndex = 2
  var realm: Realm!
  var published: Published!
  var editionManager: EditionManager? {
    return SessionManager.instance.editionManager
  }
  
  override func loadView() {
    super.loadView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "이미지보카"
    realm = try! Realm()

    if let editionManager = SessionManager.instance.editionManager {
      if let published = realm.objectForPrimaryKey(Published.self, key: editionManager.publishedId) {
        self.published = published
        initChildViewControllers()
        return
      }
    }
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
//    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "책장", style:  .Plain, target: self, action: "didTapLauncher:")
  }
  
  func didTapLauncher(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}

extension MainTabBarController {
  func initChildViewControllers() {
    // Learning
    initChildViewController(LearningProgressViewController(), title: "학습", image: "pen-fountain", selected: "pen-fountain-active")
    
    // Review
    initChildViewController(ReviewViewController(), title: "복습", image: "contact-book", selected: "contact-book-active")
    initCenterButton(imageName: "flashcards")
    
    initChildViewController(QuizViewController(), title: "시험", image: "write", selected: "write-active")
    
    initChildViewController(SettingsViewController(), title: "설정", image: "cog", selected: "cog-active")
  }
  
  
  func initChildViewController(childVC: UIViewController, title: String?, image: String, selected: String) {
    childVC.tabBarItem.title = title
    childVC.tabBarItem.image = UIImage(named: image)
    childVC.tabBarItem.selectedImage = UIImage(named: selected)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    childVC.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: App.primaryColor], forState:UIControlState.Selected)
    
    let childNaviagation = UINavigationController(rootViewController: childVC)
    addChildViewController(childNaviagation)
  }
}

extension MainTabBarController {
  
  func didClickFlashcards() {
    let selectedIndex = self.selectedIndex
    let tempView = viewControllers![selectedIndex].view
    print("selectedIndex=\(selectedIndex)")
    let viewModel = FlashcardsViewModel(editionManager: editionManager!)
    let groups = published.groups.sorted("position")
    let flashcardsVC = FlashcardsViewController(viewModel: viewModel, groups: groups)
    flashcardsVC.dismissViewControllerBlock = { [weak self] in
      self?.selectedIndex = selectedIndex
    }
    viewControllers![centerButtonIndex].view.addSubview(tempView)
    presentViewController(NavigationDrawerController(rootViewController: UINavigationController(rootViewController: flashcardsVC), leftViewController: nil, rightViewController: FlashcardsSideBarViewController(viewModel: viewModel, groups: groups)), animated: true, completion: {
          self.selectedIndex = selectedIndex
    })

  }
  
  func initCenterButton(imageName imageName: String) {
    let containerVC = UIViewController()
    containerVC.view.backgroundColor = App.windowBackgroundColor
    let buttonImage = UIImage(named: imageName)?.imageWithRenderingMode(.AlwaysOriginal)
    
    containerVC.tabBarItem.image = buttonImage
    containerVC.tabBarItem.tag = centerButtonIndex
    
    containerVC.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
    
    let childNaviagation = UINavigationController(rootViewController: containerVC)
    addChildViewController(childNaviagation)
  }
  
  override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    if item.tag == centerButtonIndex {
      didClickFlashcards()
    }
  }
  
}
