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
import Swifter

class TweetViewController : UIViewController {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    let config:Config = Config.sharedInstance
    var tweet: JSON = nil
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
        
        let user = tweet["user"]

        self.name?.text = user["name"].string
        self.screenName?.text = user["screen_name"].string
        self.textView?.text = tweet["text"].string
        self.textView?.dataDetectorTypes = .link
        //self.titleText?.title = (user?["name"] as? String)! + "のツイート"
        
        // アイコンのURLをとってきてプロトコルをHTTPに変更
        let urlString = user["profile_image_url_https"].string!
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
        if let imageUrlString = tweet["entities"]["urls"]["expanded_url"].string {
            url = URL(string: imageUrlString)
        }
    }
    
    @IBAction func retweet(_ sender: Any) {
        
        if(retweeted)
        {
            self.handleError(msg: "もうリツイートしたにゃん\n")
            return
        }
 
        let id = tweet["id_str"].string!

        TwitterWrapper.getInstance().retweetTweet(forID: id, success: { status in

            self.retweeted = true
            self.handleError(msg: "リツートしたにゃん")
        }, failure: { error in
            self.handleError(msg: "エラーだにゃん\n\nHTTP\(error.localizedDescription)")
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let replyViewController = segue.destination as? ReplyViewController {
            
            replyViewController.tweet = self.tweet
        }
    }
    
    @IBAction func sendLike(_ sender: Any) {

        let id = tweet["id_str"].string!

        TwitterWrapper.getInstance().favoriteTweet(forID: id, success: { status in

            self.retweeted = true
            self.setLabel(text: "いいね！したにゃん")
        }, failure: { error in
            self.handleError(msg: "エラーだにゃん\n\nHTTP\(error.localizedDescription)")
        })

    }
}
