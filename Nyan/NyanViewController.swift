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
    @IBOutlet weak var autoExitSwitch: UISwitch!
    @IBOutlet weak var autoExitLabel: UILabel!
    
    var accountStore:ACAccountStore = ACAccountStore()
    let semaphore = DispatchSemaphore(value: 1)
    let useDefaults = UserDefaults.standard
    let config:Config = Config.sharedInstance
    var mediaId:String = ""
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

    override func viewWillAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        sendNyan()
        showAutoExitSwitch()
    }
    
    @IBAction func autoExitSwichAction(_ sender: UISwitch)
    {
        // disable auto exit
        self.config.setAutoExit(sender.isOn)

        OperationQueue().addOperation({
            self.goToConfigView()
        })
    }
    
    func showAutoExitSwitch()
    {
        autoExitSwitch.setOn(config.autoExit, animated: true)
        autoExitSwitch.isHidden = !config.autoExit
        autoExitLabel.isHidden = !config.autoExit
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        DispatchQueue.global().async()
        {
            // exit 2 sec later
            sleep(2)

            if(self.config.autoExit) {
                // exit automatically
                exit(1)
            } else {
                // back to config view
                self.goToConfigView()
            }
        }
    }
    
    func goToConfigView () -> Void
    {
        let storyboard: UIStoryboard = self.storyboard!
        let configView = storyboard.instantiateViewController(
            withIdentifier: "config") as! ConfigViewController

        DispatchQueue.main.async()
        {
            self.present(configView, animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func setLabel(text:String)
    {
        DispatchQueue.main.async() {
            
            if let label = self.label {
                label.text = text
            }
        }
    }
    
    func handleError(msg:String) {
        
        self.setLabel(text: msg)
    }
    
    func sendNyan () -> Void
    {
         let id:UInt32! = arc4random();
        var mediaIDs:[String] = []
        if(config.mediaId != nil) {
            // メディアIDを追加
            mediaIDs.append(config.mediaId ?? "")
        }
        TwitterWrapper.getInstance().postTweet(status: Config.sharedInstance.status, inReplyToStatusID: String(id), mediaIDs: mediaIDs, success: { status in
            
            self.setLabel(text: Config.sharedInstance.status)
        }, failure: { error in
            self.handleError(msg: "エラーだにゃん\n\nHTTP\(error.localizedDescription)")

        })
    }
}
