//
//  AppDelegate.swift
//  lingo
//
//  Created by Taehyun Park on 12/30/15.
//  Copyright © 2015 Tech Savvy Mobile Co., Ltd. All rights reserved.
//

import UIKit
import XCGLogger
import SwiftyUserDefaults
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  let log = XCGLogger.defaultInstance()
  var window: UIWindow?
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    if let window = window {
      window.backgroundColor = UIColor.whiteColor()
      window.tintColor = App.tintColor
      
      UINavigationBar.appearance().barTintColor = App.primaryColor
      UINavigationBar.appearance().tintColor = UIColor.whiteColor()
      UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
      if let token = Defaults[.token], userId = Defaults[.userId], user = Defaults[.user] {
        SessionManager.instance.userId = userId
        SessionManager.instance.token = token
        SessionManager.instance.user = user
        window.rootViewController = UINavigationController(rootViewController: LauncherViewController())
      } else{
        window.rootViewController = UINavigationController(rootViewController: LoginViewController())
      }
      
      window.makeKeyAndVisible()
    }
    initLog()
    initNotification(application)
    application.statusBarStyle = UIStatusBarStyle.LightContent
    return true
  }
  
  private func initLog() {
    log.setup(.Debug, showLogIdentifier: true, showFunctionName: true, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLogLevel: nil)
  }
  
  private func initNotification(application: UIApplication!) {
    let settings: UIUserNotificationSettings =
    UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
    application.registerUserNotificationSettings(settings)
    application.registerForRemoteNotifications()
  }
  
  private func initRealm() {
    log.debug("initializing realm")
    Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 1)
  }
  
  func application(application: UIApplication,
    didRegisterUserNotificationSettings
    notificationSettings: UIUserNotificationSettings){
      self.log.debug("\(notificationSettings)")
      
      
  }
  
  // [START receive_apns_token]
  func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
    deviceToken: NSData ) {
      let characterSet = NSCharacterSet( charactersInString: "<>" )
      
      let deviceTokenString =  ( deviceToken.description as NSString )
        .stringByTrimmingCharactersInSet( characterSet )
        .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
      Defaults[.deviceToken] = deviceTokenString
      log.debug("deviceToken=\(deviceTokenString)")
  }
  
  // [START receive_apns_token_error]
  func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
    error: NSError ) {
      print("Registration for remote notification failed with error: \(error.localizedDescription)")
      Defaults[.deviceToken] = "simulator"
  }
  
  // [START ack_message_reception]
  func application( application: UIApplication,
    didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
      log.debug("Notification received: \(userInfo)")
  }
  
  func application( application: UIApplication,
    didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
    fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
      log.debug("Notification received: \(userInfo)")
  }
}

