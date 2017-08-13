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

class ReplyViewController: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var label: UILabel!
    let accountManager = AccountManager.sharedInstance
    let config:Config = Config.sharedInstance

    var tweet: [String: Any]?
    
    override func viewDidLoad() {
        let user = tweet?["user"] as? [String:Any]
        titleBar.title = (user?["name"] as? String)! + "への返信"
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

        let user = tweet?["user"] as? [String:Any]
        let screenName = user?["screen_name"] as? String
        
        let updateUrl = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
        let msg:String = "@" +  screenName! + " " + self.message.text!
        let params = ["status" : msg, "in_reply_to_status_id" : tweet?["id_str"] as! String]
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.POST,
                                url: updateUrl as URL!, parameters: params)
        
        request?.account = accountManager.getAccount(name: config.account!)
                
        let handler: SLRequestHandler  = { (data: Data?, response: HTTPURLResponse?, error: Error?) -> Void in
            
            if error != nil {
                self.setLabel(text: "エラーだにゃん\n\(String(describing: error))")
                return
            }
            
            if let response = response {
                if(response.statusCode != 200) {
                    
                    self.setLabel(text: "エラーだにゃん\n\nHTTP\(response.statusCode)")
                    return
                }
            }
            self.setLabel(text: "送信したにゃん")
            sleep(1)

            let storyboard: UIStoryboard = self.storyboard!

            // ツイート画面に戻る
            let tweetViewController = storyboard.instantiateViewController(withIdentifier: "tweet") as! TweetViewController
            
            tweetViewController.tweet = self.tweet
            DispatchQueue.main.async() {

                self.present(tweetViewController, animated: false, completion: nil)
            }
        }
        request?.perform(handler: handler)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        if (textField == message) {
            message.resignFirstResponder()
        }
        return true
    }

}
