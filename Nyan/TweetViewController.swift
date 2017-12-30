//
//  StatusViewController.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/07/09.
//  Copyright © 2017年 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit
import Social
import Accounts
import TwitterKit

class TweetViewController : UIViewController {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    let config:Config = Config.sharedInstance
    var tweet: [String: Any]?
    var retweeted = false
    let semaphore = DispatchSemaphore(value: 1)
    var image: UIImage?
    var url: URL?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setLabel(text:String) {
        
        DispatchQueue.main.async() {
            self.message.text = text
        }
    }
    
    func handleError(msg:String) {
        
        self.setLabel(text: msg)
    }
    
    override func viewDidLoad() {
        
        let user = tweet?["user"] as? [String:Any]

        self.name?.text = user?["name"] as? String
        self.screenName?.text = user?["screen_name"] as? String
        self.textView?.text = tweet?["text"] as? String
        self.textView?.dataDetectorTypes = .link
        //self.titleText?.title = (user?["name"] as? String)! + "のツイート"
        
        // アイコンのURLをとってきてプロトコルをHTTPに変更
        let urlString = user?["profile_image_url_https"] as! String
        // キャッシュしているアイコンを取得
        if let cacheImage = config.iconCache.object(forKey: urlString as AnyObject) {
            // キャッシュ画像の設定
            icon.image = cacheImage
        }
        
        if let image = image {
            imageView.image = image
        } else {
            imageHeightConstraint.constant = 0
        }
        
        // ツイート内の画像(Twitterに送信された画像)
        if let entities = tweet?["entities"] as? [String:Any]
        {
            if let urls = entities["urls"] as? [AnyObject]
            {
                for urlsEntity in urls
                {
                    if let urlString = urlsEntity["expanded_url"]
                    {
                        url = URL(string: urlString as! String)
                    }
                }
            }
        }
    }
    
    @IBAction func retweet(_ sender: Any) {
        
        if(retweeted)
        {
            self.handleError(msg: "もうリツイートしたにゃん\n")
            return
        }
        
        let requestHandler: TWTRNetworkCompletion = { (response: URLResponse?, data: Data?, error: Error?)  in
            
            if error != nil {
                self.handleError(msg: "エラーだにゃん\n\(String(describing: error))")
                self.semaphore.signal()
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if(response.statusCode != 200)
                {
                    if(response.statusCode == 403)
                    {
                        self.handleError(msg: "もうリツイートしたにゃん\n")
                        self.retweeted = true
                        self.semaphore.signal()
                        return
                    }
                    
                    self.handleError(msg: "エラーだにゃん\n\nHTTP\(response.statusCode)")
                    self.semaphore.signal()
                    return
                }
            }
            
            self.retweeted = true
            self.handleError(msg: "リツートしたにゃん")
            self.semaphore.signal()
        }
        
        let errorHandler: ErrorHandler = {
            
            (message:String?) -> Void in
            self.setLabel(text: message!)
        }
        
        TwitterWrapper.getInstance().retweet(
            tweet: tweet,
            handler: requestHandler,
            errorHandler: errorHandler,
            semaphore: self.semaphore)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let replyViewController = segue.destination as? ReplyViewController {
            
            replyViewController.tweet = self.tweet
        }
    }
    
    @IBAction func sendLike(_ sender: Any) {
        
        let requestHandler: TWTRNetworkCompletion = { (response: URLResponse?, data: Data?, error: Error?)  in
            
            if error != nil {
                self.handleError(msg: "エラーだにゃん\n\(String(describing: error))")
                self.semaphore.signal()
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if(response.statusCode != 200) {
                    
                    self.handleError(msg: "エラーだにゃん\n\nHTTP\(response.statusCode)")
                    self.semaphore.signal()
                    return
                }
            }
            
            self.handleError(msg: "いいね！したにゃん")
            self.semaphore.signal()
        }

        let errorHandler: ErrorHandler = {
            
            (message:String?) -> Void in
            self.setLabel(text: message!)
        }
        
        TwitterWrapper.getInstance().sendLike(
            tweet: tweet,
            handler: requestHandler,
            errorHandler: errorHandler,
            semaphore: self.semaphore)
    }
}
