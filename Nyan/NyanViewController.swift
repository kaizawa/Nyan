//
//  DefaultViewController.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/04/29.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//
import UIKit
import Social
import Accounts
import Foundation

class NyanViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet var uiView: UIView!
    @IBOutlet weak var configButton: UIButton!
    
    var accountStore:ACAccountStore = ACAccountStore()
    let semaphore = DispatchSemaphore(value: 1)
    let useDefaults = UserDefaults.standard
    let config:Config = Config.sharedInstance
    let accountManager = AccountManager.sharedInstance
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendNyan()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configButton.isEnabled = config.autoExit
        
        OperationQueue().addOperation({
            // exit 1 sec later
            sleep(2)

            if(self.config.autoExit) {
                // exit automatically
                exit(1)
            } else {
                // back to config view
                let storyboard: UIStoryboard = self.storyboard!
                let configView = storyboard.instantiateViewController(withIdentifier: "config") as! ConfigViewController
                self.present(configView, animated: true, completion: nil)
            }

        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setLabel(text:String) {
        
        DispatchQueue.main.async() {
            self.label.text = text
        }
    }
    
    func handleError(msg:String) {
        
        self.setLabel(text: msg)
    }
    
    func sendNyan () -> Void {
        

        let  id:UInt32! = arc4random();
        let updateUrl = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
        let msg:String = self.config.message
        let params = ["status" : msg, "in_reply_to_status_id" : String(id)]
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: SLRequestMethod.POST,
                                url: updateUrl as URL!, parameters: params)
        
        if(config.account == nil) {
            
            if(accountManager.accounts.isEmpty) {

                self.handleError(msg: "アカウント\nないにゃん")
                self.semaphore.signal()
                return
            } else {
                // select first account for now
                request?.account = accountManager.accounts.first
            }
        } else {
            request?.account = accountManager.getAccount(name: config.account!)
        }

        self.setLabel(text: msg)
        
        let handler: SLRequestHandler  = { (data: Data?, response: HTTPURLResponse?, error: Error?) -> Void in
            
            if error != nil {
                self.handleError(msg: "エラーだにゃん\n\(String(describing: error))")
                self.semaphore.signal()
                return
            }
            
            if let response = response {
                if(response.statusCode != 200) {
                    
                    self.handleError(msg: "エラーだにゃん\n\nHTTP\(response.statusCode)")
                    self.semaphore.signal()
                    return
                }
            }
            self.semaphore.signal()
        }
        self.semaphore.wait()
        request?.perform(handler: handler)
        // wait for request process
        self.semaphore.wait()
        self.semaphore.signal()
    }
    
    @IBAction func ConfigButtonAction(_ sender: UIButton) {

        // disable auto exit
        self.config.autoExit = false
    }
}
