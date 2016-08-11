//
//  AppDelegate.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 15/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import CocoaLumberjack
import iRate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let rate = iRate.sharedInstance()
    var window: UIWindow?

    // MARK: - Lifecycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configuration
        self.configureAppLogging()
        self.configureAppRating()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext() // TODO: to external
    }

    // MARK: - Configuration
    func configureAppLogging() {
        // Cocoa Lubmerjack
        DDLog.addLogger(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        DDLog.addLogger(DDASLLogger.sharedInstance()) // ASL = Apple System Logs
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60*60*24  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.addLogger(fileLogger)
    }
    
    func configureAppRating() {
        self.rate.appStoreID = Defined.Application.AppStoreID
        self.rate.promptAtLaunch = Defined.Application.RateAtLaunch
        self.rate.daysUntilPrompt = Defined.Application.RateAfterDays
        self.rate.usesUntilPrompt = Defined.Application.RateAfterUses
        self.rate.eventsUntilPrompt = Defined.Application.RateAfterEvents
        self.rate.useUIAlertControllerIfAvailable = true
    }
    
}

