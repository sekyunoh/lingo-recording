//
//  View.swift
//  Shelf
//
//  Created by Hirohisa Kawasaki on 3/14/15.
//  Copyright (c) 2015 Hirohisa Kawasaki. All rights reserved.
//

import UIKit

public protocol ViewDelegate {
  func shelfView(shelfView: ShelfView, didSelectItemAtIndexPath indexPath: NSIndexPath)
}

public protocol ViewDataSource {
  func numberOfSectionsInShelfView(shelfView: ShelfView) -> Int
  func shelfView(shelfView: ShelfView, numberOfItemsInSection section: Int) -> Int
  
  func shelfView(shelfView: ShelfView, itemCell cell: ItemCell, indexPath: NSIndexPath)
  func shelfView(shelfView: ShelfView, sectionCell cell: SectionCell, titleForHeaderInSection section: Int)
//  func headerViewsInShelfView(shelfView: ShelfView) -> [UIView]
}

public class ShelfView: UIView {
  static let sectionCell = "SectionCell"
  static let itemCell = "ItemCell"
  
  public var delegate: ViewDelegate?
  public var dataSource: ViewDataSource? {
    didSet {
      reloadData()
    }
  }
  
  class DataController: NSObject {
    weak var view: ShelfView?
  }
  let dataController = DataController()
  let refreshControl = UIRefreshControl()
  let tableView = UITableView()
//  let headerView = HeaderView()
//  let headerView: HeaderView = {
//    return UINib(nibName: "HeaderView", bundle: NSBundle(forClass: ShelfView.self)).instantiateWithOwner(nil, options: nil)[0] as! HeaderView
//  }()
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  public func reloadData() {
    tableView.reloadData()
  }
  
  public override var frame: CGRect {
    didSet {
      tableView.frame = bounds
    }
  }
}

extension ShelfView {
  
  func configure() {
    let bundle = NSBundle(forClass: ShelfView.self)
        tableView.addSubview(refreshControl)
    tableView.allowsSelection = false
    tableView.estimatedRowHeight = 200
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.registerNib(UINib(nibName: "SectionCell", bundle: bundle), forCellReuseIdentifier: "SectionCell")
    addSubview(tableView)
    
    dataController.view = self
    tableView.delegate = self
    tableView.dataSource = dataController
//    tableView.separatorColor = UIColor.clearColor()
//    tableView.addSubview(headerView)
//    tableView.tableHeaderView = UIView(frame: headerView.frame)
    tableView.tableFooterView = UIView();
  }
}

extension ShelfView: UITableViewDelegate {
  
//  public func scrollViewDidScroll(scrollView: UIScrollView) {
//    
//    var origin = CGPointZero
//    if scrollView.contentOffset.y + scrollView.contentInset.top < 0 {
//      let diff = scrollView.contentOffset.y + scrollView.contentInset.top
//      origin = CGPoint(x: 0, y: diff)
//    }
//    var frame = headerView.frame
//    frame.origin = origin
//    headerView.frame = frame
//  }
}