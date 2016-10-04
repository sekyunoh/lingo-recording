//
//  FlashcardsSideBarViewController.swift
//  lingo
//
//  Created by Taehyun Park on 2/15/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import SnapKit
import Material
import RealmSwift

private struct Item {
  var text: String
  var imageName: String
  var selected: Bool
}


class FlashcardsSideBarViewController: ViewController {
  /// A tableView used to display navigation items.
  private let tableView: UITableView = UITableView()
  
  
  let viewModel: FlashcardsViewModel
  var indexPath: NSIndexPath?
  
  
  init(viewModel: FlashcardsViewModel!, groups: Results<PublishedGroup>!) {
    self.viewModel = viewModel
    self.groups = groups
    super.init(nibName: nil, bundle: nil)
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  let groups: Results<PublishedGroup>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
    prepareTableView()
    viewModel.indexPathDriver.driveNext {
      self.indexPath = $0
      self.tableView.reloadData()
      self.tableView.scrollToRowAtIndexPath($0, atScrollPosition: .Top, animated: false)
      }.addDisposableTo(disposeBag)
  }
  
  /// General preparation statements.
  private func prepareView() {
    view.backgroundColor = MaterialColor.blueGrey.darken4
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  
  /// Prepares the tableView.
  private func prepareTableView() {
    tableView.registerClass(SideBarTableCell.self, forCellReuseIdentifier: "SideBarCell")
    tableView.backgroundColor = MaterialColor.clear
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .None
    
    // Use MaterialLayout to easily align the tableView.
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    //MaterialLayout.alignToParent(view, child: tableView)
    Layout.vertically(view, child: tableView)
    Layout.horizontally(view, child: tableView)
  }

}

/// TableViewDataSource methods.
extension FlashcardsSideBarViewController: UITableViewDataSource {
  /// Determines the number of rows in the tableView.
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return groups[section].numberOfWords
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return groups[section].name
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return groups.count
  }
  
  /// Prepares the cells within the tableView.
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SideBarCell", forIndexPath: indexPath) as UITableViewCell
    cell.backgroundColor = MaterialColor.clear
    
    cell.selectionStyle = .None
    cell.textLabel!.text = groups[indexPath.section].groupWords[indexPath.row].word.word
    cell.textLabel!.textColor = MaterialColor.white
    cell.textLabel!.font = RobotoFont.medium
    cell.imageView!.tintColor = MaterialColor.cyan.lighten4
    
    if self.indexPath != nil && self.indexPath! == indexPath {
      cell.textLabel!.textColor = MaterialColor.cyan.lighten3
    }
    
    return cell
  }
}

/// UITableViewDelegate methods.
extension FlashcardsSideBarViewController: UITableViewDelegate {
  /// Sets the tableView cell height.
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 48
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 24
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView().then {
      $0.backgroundColor  = MaterialColor.blueGrey.darken3
    }
    let group = groups[section]
    let sectionLabel = UILabel().then {
      $0.textColor = MaterialColor.white
      $0.font = UIFont.boldSystemFontOfSize(14.0)
      $0.text = group.name
    }
    view.addSubview(sectionLabel)
    sectionLabel.snp_makeConstraints {
      $0.left.equalTo(view).offset(8)
      $0.centerY.equalTo(view)
    }
    return view
  }
  
  /// Select item at row in tableView.
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("Item selected \(indexPath)")
    self.indexPath = indexPath
    viewModel.indexPath.value = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)
    if let slideNavigationVC = self.parentViewController as? NavigationDrawerController {
      slideNavigationVC.closeRightView()
    }
  }
}
