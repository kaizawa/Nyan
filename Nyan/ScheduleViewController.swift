//
//  ScheduleViewController.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/09/11.
//  Copyright © 2017年 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit

class ScheduleViewController: UIViewController {

    let config:Config = Config.sharedInstance
    @IBOutlet weak var datePicker: UIDatePicker!
    static var workItem: DispatchWorkItem?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.setValue(false, forKey: "highlightsToday")
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        self.config.setScheduledDate(datePicker.date)
        
        let nextView = self.storyboard!.instantiateViewController(withIdentifier: "config") as! ConfigViewController
        
        let sinceNow = datePicker.date.timeIntervalSinceNow
        
        ScheduleViewController.workItem = DispatchWorkItem() {
            
            // double check if schedule tweet is still configured
            if let scheduledDate = self.config.scheduledDate  {
                
                if (scheduledDate.timeIntervalSinceNow <= 0 ) {
                    let storyboard: UIStoryboard = self.storyboard!
                    let nyanView = storyboard.instantiateViewController(withIdentifier: "nyan") as! NyanViewController
                    nyanView.sendNyan()
                    
                    DispatchQueue.main.async {
                        
                        self.config.setScheduledDate(nil)
                    }
                }
            }
        }
        
        // run background thread
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + sinceNow, execute:ScheduleViewController.workItem!)
        
        DispatchQueue.main.async() {
            
            self.present(nextView, animated: false, completion: nil)
        }
    }
    
    
}
