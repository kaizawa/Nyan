//
//  Config.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/04/29.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit

class Config {
    
    static let sharedInstance = Config()
    
    var tweetOnBoot:Bool
    var autoExit:Bool
    var message:String
    var account:String?
    let TWEET_ON_BOOT_NAME:String = "tweetOnBoot"
    let AUTO_EXIT_NAME:String = "autoExit"
    let MESSAGE_NAME:String = "message"
    let ACCOUNT_NAME:String = "account"
    let DEFAULT_MESSAGE:String = "にゃーん"
    var iconCache = NSCache<AnyObject, UIImage>()


    let userDefaults = UserDefaults.standard
    
    private init() {

        if(userDefaults.object(forKey: TWEET_ON_BOOT_NAME) == nil) {
            tweetOnBoot = false
        } else {
            tweetOnBoot = userDefaults.bool(forKey: TWEET_ON_BOOT_NAME)
        }
        
        if(userDefaults.object(forKey: AUTO_EXIT_NAME) == nil) {
            autoExit = false
        } else {
            autoExit = userDefaults.bool(forKey: AUTO_EXIT_NAME)
        }
        
        if(userDefaults.object(forKey: MESSAGE_NAME) == nil) {
            message = DEFAULT_MESSAGE
        } else {
            message = userDefaults.string(forKey: MESSAGE_NAME)!
        }
        if(userDefaults.object(forKey: ACCOUNT_NAME) == nil) {
            account = nil
        } else {
            account = userDefaults.string(forKey: ACCOUNT_NAME)!
        }
    }
    
    func setTweetOnBoot (newVal:Bool) {

        tweetOnBoot = newVal
        userDefaults.set(tweetOnBoot, forKey: TWEET_ON_BOOT_NAME)
        userDefaults.synchronize()
    }

    func setAutoExit (newVal:Bool){
        
        autoExit = newVal
        userDefaults.set(autoExit, forKey: AUTO_EXIT_NAME)
        userDefaults.synchronize()
    }
    
    func setMessage (newVal:String) {
        
        message = newVal
        userDefaults.set(message, forKey: MESSAGE_NAME)
        userDefaults.synchronize()
    }
    
    func setAccount(newVal:String){

        account = newVal
        userDefaults.set(account, forKey: ACCOUNT_NAME)
        userDefaults.synchronize()
    }
    
}
