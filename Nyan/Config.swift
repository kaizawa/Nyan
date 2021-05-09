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
    var status:String
    var account:String?
    var image:UIImage?
    var mediaId:String?
    var scheduledDate:Date?
    var tokenKey:String?
    var tokenSecret:String?
    
    static let TWEET_ON_BOOT_NAME:String = "tweetOnBoot"
    static let AUTO_EXIT_NAME:String = "autoExit"
    static let STATUS_NAME:String = "status"
    static let ACCOUNT_NAME:String = "account"
    static let IMAGE_NAME:String = "image"
    static let MEDIA_ID_NAME:String = "media_ids"
    static let TOKEN_KEY:String = "token_key"
    static let TOKEN_SECRET:String = "token_secret"
    
    let DEFAULT_STATUS:String = "にゃーん"
    var iconCache = NSCache<AnyObject, UIImage>()
    

    let userDefaults = UserDefaults.standard
    
    private init() {

        if(userDefaults.object(forKey: Config.TWEET_ON_BOOT_NAME) == nil) {
            tweetOnBoot = false
        } else {
            tweetOnBoot = userDefaults.bool(forKey: Config.TWEET_ON_BOOT_NAME)
        }
        
        if(userDefaults.object(forKey: Config.AUTO_EXIT_NAME) == nil) {
            autoExit = false
        } else {
            autoExit = userDefaults.bool(forKey: Config.AUTO_EXIT_NAME)
        }
        
        if(userDefaults.object(forKey: Config.STATUS_NAME) == nil) {
            status = DEFAULT_STATUS
        } else {
            status = userDefaults.string(forKey: Config.STATUS_NAME)!
        }
        if(userDefaults.object(forKey: Config.ACCOUNT_NAME) == nil) {
            account = nil
        } else {
            account = userDefaults.string(forKey: Config.ACCOUNT_NAME)!
        }
        if(userDefaults.object(forKey: Config.IMAGE_NAME) == nil) {
            image = nil
        } else {
            let imageData = userDefaults.object(forKey: Config.IMAGE_NAME) as! NSData?
            image = UIImage(data:imageData! as Data)
        }
        if(userDefaults.object(forKey: Config.MEDIA_ID_NAME) == nil) {
            mediaId = nil
        } else {
            mediaId = userDefaults.string(forKey: Config.MEDIA_ID_NAME)!
        }
        scheduledDate = nil
        
        if(userDefaults.object(forKey: Config.TOKEN_KEY) == nil) {
            tokenKey = nil
        } else {
            tokenKey = userDefaults.string(forKey: Config.TOKEN_KEY)!
        }
        
        if(userDefaults.object(forKey: Config.TOKEN_SECRET) == nil) {
            tokenSecret = nil
        } else {
            tokenSecret =  userDefaults.string(forKey: Config.TOKEN_SECRET)!
        }
    }
    
    func setTokenKey(_ newVal:String){

        tokenKey = newVal
        userDefaults.set(tokenKey, forKey: Config.TOKEN_KEY)
        userDefaults.synchronize()
    }
    
    func setTokenSecret(_ newVal:String){

        tokenSecret = newVal
        userDefaults.set(tokenSecret, forKey: Config.TOKEN_SECRET)
        userDefaults.synchronize()
    }
    
    func setScheduledDate(_ newVal:Date?) {
        scheduledDate = newVal
    }
    
    func setTweetOnBoot (_ newVal:Bool) {

        tweetOnBoot = newVal
        userDefaults.set(tweetOnBoot, forKey: Config.TWEET_ON_BOOT_NAME)
        userDefaults.synchronize()
    }

    func setAutoExit (_ newVal:Bool){
        
        autoExit = newVal
        userDefaults.set(autoExit, forKey: Config.AUTO_EXIT_NAME)
        userDefaults.synchronize()
    }
    
    func setStatus (_ newVal:String) {
        
        status = newVal
        userDefaults.set(status, forKey: Config.STATUS_NAME)
        userDefaults.synchronize()
    }
    
    func setAccount(_ newVal:String){

        account = newVal
        userDefaults.set(account, forKey: Config.ACCOUNT_NAME)
        userDefaults.synchronize()
    }
    
    func setImage(_ newVal:UIImage?)
    {
        image = newVal
        
        if let newVal = newVal {
            
            let imageData = newVal.jpegData(compressionQuality: 1)
            userDefaults.set(imageData, forKey: Config.IMAGE_NAME)
            userDefaults.synchronize()
        }
        else {
            userDefaults.removeObject(forKey: Config.IMAGE_NAME)
            userDefaults.synchronize()
        }
    }

    func setMediaId(_ newVal:String?)
    {
        mediaId = newVal
        
        if let newVal = newVal {

            userDefaults.set(newVal, forKey: Config.MEDIA_ID_NAME)
            userDefaults.synchronize()
        }
        else {
            userDefaults.removeObject(forKey: Config.MEDIA_ID_NAME)
            userDefaults.synchronize()
        }

    }
    
}
