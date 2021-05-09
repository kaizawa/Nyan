//
//  ConfigViewController.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/04/29.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import UIKit
import Accounts
import SafariServices
import AuthenticationServices
import Swifter

class ConfigViewController: UIViewController, UITextFieldDelegate  {
        
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var tweetOnBoot: UISwitch!
    @IBOutlet weak var autoExit: UISwitch!
    @IBOutlet weak var account: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var scheduleSwitch: UISwitch!
    @IBOutlet weak var scheduleDateLabel: UILabel!

    private var jsonResult: [JSON] = []

    @IBAction func accountAction(_ sender: UITextField) {
        
        // You can change the authorizationMode to test different results via the AppDelegate
        switch authorizationMode
        {
        case .browser:
            authorizeWithWebLogin()
        case .sso:
            authorizeWithSSO()
        }       
    }

    private func authorizeWithWebLogin() {
        // this URL is registered in https://developer.twitter.com/en/apps/14625937
        let callbackUrl = URL(string: "swifter-JVnDZmANHjkzU1Tx4awnXw6B0://")!
        if #available(iOS 13.0, *) {
            
            TwitterWrapper.getInstance().authorize(withProvider: self, callbackURL: callbackUrl) { _, _ in
                if let accessToken = TwitterWrapper.getInstance().client.credential?.accessToken
                {
                    Config.sharedInstance.setTokenKey(accessToken.key)
                    Config.sharedInstance.setTokenSecret(accessToken.secret)
                    
                    if(TwitterWrapper.getInstance().client.credential != nil &&
                        TwitterWrapper.getInstance().client.credential?.accessToken != nil)
                    {
                        let account = TwitterWrapper.getInstance().client.credential?.accessToken?.screenName ?? ""
                        Config.sharedInstance.setAccount(account)
                        self.account.text = account
                    }
                }

            } failure: { error in
                self.alert(title: "Error", message: error.localizedDescription)
            }
        } else {
            TwitterWrapper.getInstance().authorize(withCallback: callbackUrl, presentingFrom: self) { _, _ in
                self.fetchTwitterHomeStream()
            } failure: { error in
                self.alert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    private func authorizeWithSSO() {
        TwitterWrapper.getInstance().authorizeSSO { _ in
            if let accessToken = TwitterWrapper.getInstance().client.credential?.accessToken {
                Config.sharedInstance.setTokenKey(accessToken.key)
                Config.sharedInstance.setTokenSecret(accessToken.secret)
            }
        } failure: { error in
            self.alert(title: "Error", message: error.localizedDescription)
        }
    }

    private func fetchTwitterHomeStream() {
        TwitterWrapper.getInstance().getHomeTimeline(count: 20) { json in
            // Successfully fetched timeline, so lets create and push the table view
            self.jsonResult = json.array ?? []
            self.performSegue(withIdentifier: "showTweets", sender: self)
        } failure: { error in
            self.alert(title: "Error", message: error.localizedDescription)
        }
    }

    private func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
      
    @IBAction func timeLineButtonAction(_ sender: UIBarButtonItem)
    {
//        config.setAccount(self.account.text!)
        config.setStatus(self.status.text!)
        let nextView = self.storyboard!.instantiateViewController(withIdentifier: "timeline") as! TimeLineViewController
        
        DispatchQueue.main.async() {
            
            self.present(nextView, animated: false, completion: nil)
        }
    }
    
    @IBAction func cameraButtonAction(_ sender: UIBarButtonItem)
    {
        config.setAccount(self.account.text!)
        config.setStatus(self.status.text!)
        let nextView = self.storyboard!.instantiateViewController(withIdentifier: "camera") as! CameraViewController
        
        DispatchQueue.main.async() {
            
            self.present(nextView, animated: false, completion: nil)
        }
    }
    
    @IBAction func scheduleSwitchAction(_ sender: UISwitch)
    {
        config.setStatus(self.status.text!)
        
        if(sender.isOn)
        {
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "schedule") as! ScheduleViewController
            
            DispatchQueue.main.async() {
                
                self.present(nextView, animated: false, completion: nil)
            }
        } else {

            // cancel existing task
            if let workItem = ScheduleViewController.workItem
            {
                workItem.cancel()
                ScheduleViewController.workItem = nil
            }
            config.setScheduledDate(nil)
            DispatchQueue.main.async() {
                self.scheduleDateLabel.isHidden = true
                self.autoExit.isEnabled = true
            }
        }
    }

    let config = Config.sharedInstance
    var image:UIImage? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        status.delegate = self;
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
        
        // register notification so that viewWillAppear will be called when entring foreground
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.viewWillAppear),
            name: Notification.Name(rawValue:"willEnterForeground"), object: nil)
        
        autoExit.isOn = config.autoExit
        tweetOnBoot.isOn = config.tweetOnBoot
        status.text = config.status
        
        if (config.tokenKey != nil && config.tokenSecret != nil && config.account != nil)
        {
            account.text = config.account
        }
        else {            
           account.text = "アカウントがありません"
        }
        
        if let scheduledDate = config.scheduledDate {
            
            // Schedule Tweet is configured
            DispatchQueue.main.async() {
                                
                self.scheduleSwitch.isOn = true
                
                let dateFormatter = DateFormatter()
                dateFormatter.setLocalizedDateFormatFromTemplate("M/d HH:mm")
                self.scheduleDateLabel.text = dateFormatter.string(from: scheduledDate) + " に自動ツイート"
                self.scheduleDateLabel.isHidden = false

                // auto exit is disabled because schedule tweet
                self.autoExit.isOn = false
                self.config.setAutoExit(false)
                self.autoExit.isEnabled = false
            }
        } else {
        
            DispatchQueue.main.async() {
                
                self.scheduleSwitch.isOn = false
                self.scheduleDateLabel.isHidden  = true
                self.autoExit.isEnabled = true
            }
        }
        
        if(image != nil){
            imageView.image = image
            deleteImageButton.isHidden = false
        } else {
            if(config.image != nil) {
                image = config.image
                imageView.image = image
                deleteImageButton.isHidden = false
            } else {
                deleteImageButton.isHidden = true
            }
        }
     }
    
    @IBAction func deleteImageButtonAction(_ sender: UIButton)
    {
        
        DispatchQueue.main.async() {
            self.image = nil
            self.imageView.image = nil
            self.config.setImage(nil)
            self.config.setMediaId(nil)
            self.deleteImageButton.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tweetOnBootSwitchAction(_ sender: UISwitch) {
        self.config.setTweetOnBoot(sender.isOn)
    }

    @IBAction func autoExitSwitchAction(_ sender: UISwitch) {
        self.config.setAutoExit(sender.isOn)
    }
    
    @IBAction func statusTextAction(_ sender: UITextField) {
        self.config.setStatus(sender.text!)
    }
    
    @IBAction func tweetButtonAction(_ sender: Any) {
        
//        config.setAccount(self.account.text!)
        config.setStatus(self.status.text!)
        
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "nyan") as! NyanViewController
        self.present(nextView, animated: false, completion: nil)

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func donePicker (sender: UIButton) {
        print("done picker called")
        account.resignFirstResponder()

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{

        if (textField == status) {

            status.resignFirstResponder()
        }
        else if(textField == account) {
            
            account.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.view.endEditing(true)
    }
}

extension ConfigViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// This is need for ASWebAuthenticationSession
@available(iOS 13.0, *)
extension ConfigViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}
