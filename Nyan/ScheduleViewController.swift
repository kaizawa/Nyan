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
    static var workItem: DispatchWorkItem?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
            
        if #available(iOS 13.4, *){
            //todo: can't set text color to white.
            //Thus, setting BG color of ScheduleViewController to white and set text color to black for now.
            datePicker.setValue(UIColor.black, forKey: "textColor")
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.setValue(true, forKey: "highlightsToday")
        }
        
        if #available(iOS 14.0, *){
            datePicker.preferredDatePickerStyle = .inline
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        self.config.setScheduledDate(datePicker.date)
        
        let nextView = self.storyboard!.instantiateViewController(withIdentifier: "config") as! ConfigViewController
        
        let sinceNow = datePicker.date.timeIntervalSinceNow
        
        ScheduleViewController.workItem = DispatchWorkItem() {
            
            // double check if schedule tweet is still configured
            if let scheduledDate = self.config.scheduledDate  {
                
                if (scheduledDate.timeIntervalSinceNow <= 0 ) {
                    // storyboard must be called from main thread
                    DispatchQueue.main.async
                    {
                        let storyboard: UIStoryboard = self.storyboard!
                        let nyanView = storyboard.instantiateViewController(withIdentifier: "nyan") as! NyanViewController
                        nyanView.sendNyan()
                    }
                    
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
