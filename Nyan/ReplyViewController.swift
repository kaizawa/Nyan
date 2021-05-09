//
//  ReplyViewController.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/07/09.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit
import Social
import Swifter

class ReplyViewController: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var label: UILabel!
    let config:Config = Config.sharedInstance
    let semaphore = DispatchSemaphore(value: 1)

    var tweet: JSON = nil
    
    override func viewDidLoad() {
        let user = tweet["user"]
        titleBar.title = (user["name"].string)! + "への返信"
        message.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let tweetViewController = segue.destination as? TweetViewController {
            
            tweetViewController.tweet = self.tweet
        }
    }
    
    func setLabel(text:String) {
        
        DispatchQueue.main.async() {
            self.label.text = text
        }
    }
    
    @IBAction func sendReply(_ sender: Any) {
          
        let id = tweet["id_str"].string!

        TwitterWrapper.getInstance().postTweet(status: self.message.text!, inReplyToStatusID: String(id), success: { status in
            self.setLabel(text: "送信したにゃん")
            sleep(1)

        }, failure: { error in
            self.setLabel(text: "エラーだにゃん\n\nHTTP\(error.localizedDescription)")
            return
        })
        sleep(1)
        // ツイート画面に戻る
        let tweetViewController = storyboard?.instantiateViewController(withIdentifier: "tweet") as! TweetViewController
        
        tweetViewController.tweet = self.tweet

        DispatchQueue.main.async() {

            self.present(tweetViewController, animated: false, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        if (textField == message) {
            message.resignFirstResponder()
        }
        return true
    }

}
