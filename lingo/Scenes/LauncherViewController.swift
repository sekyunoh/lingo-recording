//
//  LauncherViewController.swift
//  lingo
//
//  Created by Taehyun Park on 1/5/16.
//  Copyright © 2016 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import RealmSwift
#if !RX_NO_MODULE
  import RxSwift
#endif
import SwiftyUserDefaults

class CollectionViewCell: UICollectionViewCell {
  
  let label: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.whiteColor()
    return label
  }()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    label.frame = bounds
    contentView.addSubview(label)
  }
  
  
}

class LauncherViewController: ViewController, ViewDataSource, ViewDelegate {
  
  var realm: Realm!
  var series: Results<Series>!
  var schoolId: Int!
  
  var refreshControl: UIRefreshControl!
  
  override func loadView() {
    super.loadView()
    view = LauncherView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let authUser = SessionManager.instance.user else {
      DefaultWireframe.switchRootViewController(UINavigationController(rootViewController: LoginViewController()), animated: true, completion: nil)
      return
    }
    
    guard let schoolId = authUser["schoolId"] as? Int else {
      DefaultWireframe.switchRootViewController(UINavigationController(rootViewController: LoginViewController()), animated: true, completion: nil)
      return
    }
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "공지사항", style: .Plain, target: self, action: "didClickLogout:")
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "프로필", style:  .Plain, target: self, action: "didClickProfile:")
    
    self.schoolId = schoolId
    realm = try! Realm()
    series = realm.objects(Series).filter("schoolId == \(schoolId)").sorted("position")
    self.title = "이미지 보카"
    let view = self.view as! LauncherView
    view.shelfView.delegate = self
    view.shelfView.dataSource = self
    view.setLogo(schoolId)
    refreshControl = view.shelfView.refreshControl
    refreshControl.rx_changed.asDriver().driveNext(refresh).addDisposableTo(disposeBag)
    if series.isEmpty {
      refresh()
    } else {
      HUD.success()
    }
  }
  
  private func refresh() {
    API.instance.getSeries()
      .subscribe(onNext: { [weak self] response in
        guard let SELF = self else {
          return
        }
        if let series = response.data {
          let realm = try! Realm()
          // get a list of series from device
          var seriesIds = realm.objects(Series).filter("schoolId == \(SELF.schoolId)").map { $0.id }
          try! realm.write {
            for s in series {
              s.schoolId = SELF.schoolId
              if let seriesIndex = seriesIds.indexOf(s.id) {
                seriesIds.removeAtIndex(seriesIndex)
              }
              
              if let realmSeries = realm.objects(Series).filter("id == \(s.id)").first {
                // check if the persisted realm should be updated
                if realmSeries.version != s.version || realmSeries.schoolId != s.schoolId {
                  realmSeries.name = s.name
                  realmSeries.position = s.position
                  realmSeries.color = s.color
                  realmSeries.schoolId = s.schoolId
                  realmSeries.version = s.version
                }
                var publishedMap =  [Int : Published]()
                for p in s.publisheds {
                  publishedMap[p.id] = p
                }
                
                var unpublisheds = [Published]()
                
                for p in realmSeries.publisheds {
                  // if the published from device is in server, sync
                  if let newPublished = publishedMap.removeValueForKey(p.id) {
                    // if the version doesn't match, update
                    if newPublished.version != p.version {
                      realm.add(newPublished, update: true)
                      if let publishedStatus = realm.objects(PublishedStatus).filter("id == \(p.id)").first {
                        if publishedStatus.status == PublishedStatus.wordsLoaded {
                          if newPublished.checksum == publishedStatus.checksum {
                            publishedStatus.status = PublishedStatus.validated
                          } else {
                            publishedStatus.status = PublishedStatus.none
                          }
                        }
                      }
                    } else if newPublished.position != p.position {
                      p.position = newPublished.position
                    }
                    
                  } else {
                    // this published has been unpublished,
                    unpublisheds.append(p)
                  }
                }
                
                for unpublished in unpublisheds {
                  realm.delete(unpublished)
                }
                
                // if there is a newly published, add it to the realm
                if publishedMap.count > 0 {
                  for p in publishedMap.values {
                    if let realmPublished = realm.objects(Published).filter("id == \(p.id)").first {
                      realmSeries.publisheds.append(realmPublished)
                    } else {
                      realmSeries.publisheds.append(p)
                    }
                  }
                }
              } else {
                realm.add(s, update: true)
              }
            }
            
            for seriesId in seriesIds {
              // delete this series
              if let series = realm.objects(Series).filter("id==\(seriesId)").first {
                realm.delete(series)
              }
            }
          }
          
          dispatch_async(dispatch_get_main_queue()) {
            SELF.realm.refresh()
            SELF.log.debug("series=\(SELF.series)")
            let view = SELF.view as! LauncherView
            view.shelfView.reloadData()
            if SELF.refreshControl.refreshing {
              SELF.refreshControl.endRefreshing()
            }
            HUD.success()
          }
        }
        
        }, onError: { error in
          dispatch_async(dispatch_get_main_queue()) {
            HUD.error()
          }
      })
      .addDisposableTo(disposeBag)
  }
  
  func didClickLogout(item: UIBarButtonItem) {
    // TODO: display logout alert
    Defaults[.userId] = nil
    Defaults[.user] = nil
    try! realm.write {
      realm.deleteAll()
    }
    if let window = self.view.window where window.rootViewController is LoginViewController{
      self.dismissViewControllerAnimated(true, completion: nil)
    } else {
      self.presentViewController(UINavigationController(rootViewController: LoginViewController()), animated: true, completion: nil)
    }
  }
  
  func didClickProfile(item: UIBarButtonItem) {
    presentViewController(UINavigationController(rootViewController: ProfileViewController()), animated: true, completion: nil)
  }
  
  // MARK: DataSource
  
  func numberOfSectionsInShelfView(shelfView: ShelfView) -> Int {
    return series.count
  }
  
  func shelfView(shelfView: ShelfView, numberOfItemsInSection section: Int) -> Int {
    return series[section].publisheds.count
  }
  
  // MARK: Delegate
  func shelfView(shelfView: ShelfView, itemCell cell: ItemCell, indexPath: NSIndexPath) {
    let publisheds = series[indexPath.section].publisheds.sorted("position")
    let published = publisheds[indexPath.row]
    cell.imageView.kf_setImageWithURL(NSURL(string: "\(App.resource)/published/\(published.id)/icon")!)
    cell.mainLabel.text = published.name
    // check if this has been downloaded
    if let status = realm.objects(PublishedStatus).filter("id == \(published.id)").first where status != PublishedStatus.none {
      cell.imageView.alpha = 1
    } else {
      cell.imageView.alpha = 0.5
    }
    
  }
  
  func shelfView(shelfView: ShelfView, sectionCell cell: SectionCell, titleForHeaderInSection section: Int) {
    let series = self.series[section]
    cell.titleLabel.text = " \(series.name) "
    cell.titleLabel.backgroundColor = UIColor.init(rgba: series.color, defaultColor: App.primaryColor)
  }
  
  func shelfView(shelfView: ShelfView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if isBeingDismissed() || isBeingPresented() {
      return
    }
    log.debug("select indexPath section:\(indexPath.section), item:\(indexPath.row)")
    // check if this has been downloaded
    let series = self.series[indexPath.section]
    let publisheds = series.publisheds.sorted("position")
    let published = publisheds[indexPath.row]
    if let status = realm.objects(PublishedStatus).filter("id == \(published.id)").first where status != PublishedStatus.none {
      // downloaded
      presentEditionLoader(published)
    } else {
      // display alert
      let fileSizeInMb = published.resourceSize / 1024 / 1024
      $.wireframe.promptFor(self, title: "\(series.name) \(published.name) 다운로드", message: "해당 에디션이 기기에 존재하지 않아 단어 파일을 다운로드해야합니다. 발음/그림 파일 크기: 약: \(fileSizeInMb)MB. 데이터(3G/4G)를 사용할 경우 요금이 부과될 수 있습니다.", cancelAction: "취소", actions: ["다운로드"])
        .subscribeNext { [weak self] action in
          guard let SELF = self else {
            return
          }
          if action == "다운로드" {
            SELF.presentEditionLoader(published)
          }
          SELF.log.debug("action=\(action)")
        }.addDisposableTo(disposeBag)
    }
    
    //    let editionLoaderVC = EditionLoaderViewController()
    //    editionLoaderVC.dismissViewControllerBlock = { [weak self] in
    //      self?.log.debug("push main")
    //      self?.navigationController?.pushViewController(MainTabBarController(), animated: true)
    //    }
    //    presentViewController(editionLoaderVC, animated: true, completion: nil)
    //    presentViewController(EditionLoaderViewController(), animated: true, completion: nil)
    //    navigationController?.pushViewController(MainTabBarController(), animated: true)
  }
  
  private func presentEditionLoader(published: Published) {
    let editionLoaderVC = EditionLoaderViewController(published)
    let splashView = SplashView()
    editionLoaderVC.dismissViewControllerBlock = { [weak self] in
      self?.navigationController?.pushViewController(MainTabBarController(), animated: true) {
        splashView.removeFromSuperview()
      }
      //      self?.log.debug("removeFromSuperview")
    }
    presentViewController(editionLoaderVC, animated: true) {
      self.view.addSubview(splashView)
    }
    
    
    
  }
}

