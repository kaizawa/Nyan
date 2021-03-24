//
//  TwitterWrapper.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/08/13.
//  Copyright © 2017年 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

public typealias ErrorHandler = (String?) -> Void

class TwitterWrapper {
    
    static let sharedInstance = TwitterWrapper()
    let config:Config = Config.sharedInstance
    var session:TWTRSession?
    
    private init ()
    {
    }
    
    func setSession(session: TWTRSession?) -> Void
    {
        self.session = session
    }
    
    func getSession() -> TWTRSession?
    {
        if session == nil {
            
            if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
                
                session = TWTRTwitter.sharedInstance().sessionStore.session() as? TWTRSession
            }
        }
        return self.session;
    }
    
    static func getInstance() -> TwitterWrapper
    {
        return sharedInstance
    }
    
    private func request(requestMethod:String, urlStr:String, params:[String:String]?, handler:@escaping TWTRNetworkCompletion, errorHandler:ErrorHandler,  semaphore:DispatchSemaphore, imageData:Data?) -> Void {
    
        if let session = getSession() {
            let client = TWTRAPIClient(userID: session.userID)
            print("userid: \(session.userID)")
            var error : NSError?
            
            let request = client.urlRequest(withMethod: requestMethod, urlString: urlStr, parameters: params, error: &error)
            client.sendTwitterRequest(request, completion:handler);
            
            if let error = error {
                errorHandler("エラーだにゃん\n\(error)")

            }

        } else {
            errorHandler("アカウント\nないにゃん")
        }
    }
    
    func sendStatus(handler:@escaping TWTRNetworkCompletion, errorHandler:ErrorHandler, semaphore:DispatchSemaphore) {
        
        let status = config.status
        let id:UInt32! = arc4random();
        var params = ["status" : status, "in_reply_to_status_id" : String(id)]

        if(config.mediaId != nil) {
            // メディアIDを追加
            params["media_ids"] = config.mediaId
        }
        
        errorHandler(status)
        
        request(requestMethod: "POST",
             urlStr: "https://api.twitter.com/1.1/statuses/update.json",
             params: params,
             handler: handler,
             errorHandler: errorHandler,
             semaphore: semaphore,
             imageData: nil)

    }
    
    func uploadMedia(handler:@escaping TWTRNetworkCompletion, errorHandler:ErrorHandler, semaphore:DispatchSemaphore)
    {
        
        let imageData = config.image!.jpegData(compressionQuality: 1)
        
        guard let _ = imageData else {
            errorHandler("写真データないにゃん")
            return
        }

        let imageString = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions())        
        let params = ["media": imageString!]
        
        request(requestMethod: "POST",
             urlStr: "https://upload.twitter.com/1.1/media/upload.json",
             params: params,
             handler: handler,
             errorHandler: errorHandler,
             semaphore: semaphore,
             imageData: imageData
        )
        
    }
    
    func sendReply(tweet: [String: Any]?, status:String, handler:@escaping TWTRNetworkCompletion, errorHandler:ErrorHandler, semaphore:DispatchSemaphore)
    {
        let user = tweet?["user"] as? [String:Any]
        let screenName = user?["screen_name"] as? String
        let msg:String = "@" +  screenName! + " " + status
        let params = ["status" : msg, "in_reply_to_status_id" : tweet?["id_str"] as! String]
        
        request(requestMethod: "POST",
             urlStr: "https://api.twitter.com/1.1/statuses/update.json",
             params: params,
             handler: handler,
             errorHandler: errorHandler,
             semaphore: semaphore,
             imageData: nil)
    }
    
    func updateTimeline(handler:@escaping TWTRNetworkCompletion, errorHandler:ErrorHandler, semaphore:DispatchSemaphore) {
        
        let params = ["count": "50"]
        
        request(requestMethod: "GET",
             urlStr: "https://api.twitter.com/1.1/statuses/home_timeline.json",
             params: params,
             handler: handler,
             errorHandler: errorHandler,
             semaphore: semaphore,
             imageData: nil)
    }
    
    func retweet(tweet: [String: Any]?, handler:@escaping TWTRNetworkCompletion, errorHandler:ErrorHandler, semaphore:DispatchSemaphore) {
        
        let id = tweet?["id_str"] as? String
        
        request(requestMethod: "POST",
                urlStr: "https://api.twitter.com/1.1/statuses/retweet/" + id! + ".json",
                params: nil,
                handler: handler,
                errorHandler: errorHandler,
                semaphore: semaphore,
                imageData: nil)
    }
    
    func sendLike(tweet: [String: Any]?, handler:@escaping TWTRNetworkCompletion, errorHandler:ErrorHandler, semaphore:DispatchSemaphore) {
        
        let id:String = (tweet?["id_str"] as? String)!
        let params = ["id" : id ]
        
        request(requestMethod: "POST",
                urlStr: "https://api.twitter.com/1.1/favorites/create.json",
                params: params,
                handler: handler,
                errorHandler: errorHandler,
                semaphore: semaphore,
                imageData: nil)
    }
}
