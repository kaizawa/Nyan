//
//  AppDelegate.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/03/19.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import UIKit
import Swifter

enum AuthorizationMode {
    case browser
    case sso
    
    var isUsingSSO: Bool {
        return self == .browser
    }
}

let authorizationMode: AuthorizationMode = .browser

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundTaskIdentifier : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)


    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        // this URL is registered in https://developer.twitter.com/en/apps/14625937
        if authorizationMode.isUsingSSO {

            let callbackUrl = URL(string: "swifter-JVnDZmANHjkzU1Tx4awnXw6B0://")!
            Swifter.handleOpenURL(url, callbackURL: callbackUrl, isSSO: true)
        } else {
            let callbackUrl = URL(string: "swifter-JVnDZmANHjkzU1Tx4awnXw6B0://")!
            Swifter.handleOpenURL(url, callbackURL: callbackUrl)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        self.backgroundTaskIdentifier = application.beginBackgroundTask(){
            [weak self] in
            application.endBackgroundTask((self?.backgroundTaskIdentifier)!)
            self?.backgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        //reload account
        //AccountManager.sharedInstance.requestAccounts()
        
        // create notification
        NotificationCenter.default
            .post(name: Notification.Name(rawValue:"willEnterForeground"), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        application.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.backgroundTaskIdentifier.rawValue))
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
