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
import TwitterKit

class ReplyViewController: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var label: UILabel!
    let config:Config = Config.sharedInstance
    let semaphore = DispatchSemaphore(value: 1)

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
            
        let requestHandler: TWTRNetworkCompletion = { (response: URLResponse?, data: Data?, error: Error?)  in

            if error != nil {
                self.setLabel(text: "エラーだにゃん\n\(String(describing: error))")
                self.semaphore.signal()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse{
                if(httpResponse.statusCode != 200) {
                    
                    self.setLabel(text: "エラーだにゃん\n\nHTTP\(httpResponse.statusCode)")
                    self.semaphore.signal()
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
            self.semaphore.signal()
        }
        
        let errorHandler: ErrorHandler = {
            
            (message:String?) -> Void in
            self.setLabel(text: message!)
        }
        
        TwitterWrapper.getInstance().sendReply(
            tweet: tweet,
            status: self.message.text!,
            handler: requestHandler,
            errorHandler: errorHandler,
            semaphore: self.semaphore)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        if (textField == message) {
            message.resignFirstResponder()
        }
        return true
    }

}
