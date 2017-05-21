//
//  ConfigViewController.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/04/29.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import UIKit
import Accounts

class ConfigViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var tweetOnBoot: UISwitch!
    @IBOutlet weak var autoExit: UISwitch!
    @IBOutlet weak var account: UITextField!
    
    let config = Config.sharedInstance
    let accountManager = AccountManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated:Bool) {                
        super.viewWillAppear(animated)
        
        accountManager.requestAccounts()

        autoExit.isOn = config.autoExit
        tweetOnBoot.isOn = config.tweetOnBoot
        message.text = config.message
        
        var accountRow = 0
    
        if(config.account == nil || accountManager.getAccount(name: config.account!) == nil){
 
            // account is not saved or account is no longer exist
            if(accountManager.accounts.isEmpty) {
                account.text = "アカウントがありません"
            } else {
                // set 1st account for now
                account.text = accountManager.accounts.first?.username
                accountRow = 0
            }
        } else {
            for index in 0..<accountManager.accounts.count {

                if(accountManager.accounts[index].username == config.account) {
                    accountRow = index
                    account.text = config.account
                    break
                }
            }
        }
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100)
        picker.showsSelectionIndicator = true
        picker.selectRow(accountRow, inComponent: 0, animated: false)

        let doneButton = UIBarButtonItem(
            title: "設定", style: .plain, target: self, action: #selector(ConfigViewController.donePicker))
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.black
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        account.inputView = picker
        //toolbar doesn't work
        //account.inputAccessoryView = toolBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tweetOnBootSwitchAction(_ sender: UISwitch) {
        self.config.setTweetOnBoot(newVal: sender.isOn)
    }

    @IBAction func autoExitSwitchAction(_ sender: UISwitch) {
        self.config.setAutoExit(newVal: sender.isOn)
    }
    
    @IBAction func messageTextAction(_ sender: UITextField) {
        self.config.setMessage(newVal: sender.text!)
    }
    
    @IBAction func tweetButtonAction(_ sender: UIButton) {
        
        config.setAccount(newVal: self.account.text!)
        config.setMessage(newVal: self.message.text!)

        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "nyan") as! NyanViewController
        self.present(nextView, animated: false, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
        
        accountManager.requestAccounts()
        return accountManager.accounts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {

        return accountManager.accounts[row].username
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        
        config.setAccount(newVal: accountManager.accounts[row].username)
        account.text = accountManager.accounts[row].username
        self.account.endEditing(true)
    }
    
    func donePicker () {

        self.account.endEditing(true)
    }
}
