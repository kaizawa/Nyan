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

class TweetViewController : UIViewController {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var titleText: UINavigationItem!
    
    let accountManager = AccountManager.sharedInstance
    let config:Config = Config.sharedInstance
    var tweet: [String: Any]?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setLabel(text:String) {
        
        DispatchQueue.main.async() {
            self.label.text = text
        }
    }
    
    func handleError(msg:String) {
        
        self.setLabel(text: msg)
    }
    
    override func viewDidLoad() {
        
        let user = tweet?["user"] as? [String:Any]

        self.name?.text = user?["name"] as? String
        self.screenName?.text = user?["screen_name"] as? String
        self.status?.text = tweet?["text"] as? String
        self.titleText?.title = (user?["name"] as? String)! + "のツイート"
        
        // アイコンのURLをとってきてプロトコルをHTTPに変更
        let urlString = user?["profile_image_url_https"] as! String
        // キャッシュしているアイコンを取得
        if let cacheImage = config.iconCache.object(forKey: urlString as AnyObject) {
            // キャッシュ画像の設定
            icon.image = cacheImage
        }
    }
    
    @IBAction func retweet(_ sender: Any) {
        
        let id = tweet?["id_str"] as? String

        let updateUrl = NSURL(string: "https://api.twitter.com/1.1/statuses/retweet/" + id! + ".json")
        let params: [String: String] = [:]
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.POST,
                                url: updateUrl as URL!, parameters: params)
        
        request?.account = accountManager.getAccount(name: config.account!)

        let handler: SLRequestHandler  = { (data: Data?, response: HTTPURLResponse?, error: Error?) -> Void in
            
            if error != nil {
                self.handleError(msg: "エラーだにゃん\n\(String(describing: error))")
                return
            }
            
            if let response = response {
                if(response.statusCode != 200) {
                    
                    self.handleError(msg: "エラーだにゃん\n\nHTTP\(response.statusCode)")
                    return
                }
            }
            
            self.handleError(msg: "リツートしたにゃん")

        }
        request?.perform(handler: handler)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let replyViewController = segue.destination as? ReplyViewController {
            
            replyViewController.tweet = self.tweet
        }
    }
    
    @IBAction func sendLike(_ sender: Any) {
        
        let id = tweet?["id_str"] as! String
        
        let updateUrl = NSURL(string: "https://api.twitter.com/1.1/favorites/create.json")
        let params = ["id" : id ]
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.POST,
                                url: updateUrl as URL!, parameters: params)
        
        request?.account = accountManager.getAccount(name: config.account!)
        
        let handler: SLRequestHandler  = { (data: Data?, response: HTTPURLResponse?, error: Error?) -> Void in
            
            if error != nil {
                self.handleError(msg: "エラーだにゃん\n\(String(describing: error))")
                return
            }
            
            if let response = response {
                if(response.statusCode != 200) {
                    
                    self.handleError(msg: "エラーだにゃん\n\nHTTP\(response.statusCode)")
                    return
                }
            }
            
            self.handleError(msg: "いいね！したにゃん")            
        }
        request?.perform(handler: handler)
    }
}
