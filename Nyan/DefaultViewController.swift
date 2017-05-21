//
//  DefaultViewController.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/04/29.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import UIKit

class DefaultViewController: UIViewController {
    
    let config:Config = Config.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let storyboard: UIStoryboard = self.storyboard!
        
        if(self.config.tweetOnBoot) {
            let nextView = storyboard.instantiateViewController(withIdentifier: "nyan") as! NyanViewController
            self.present(nextView, animated: false, completion: nil)
        } else {
            let nextView = storyboard.instantiateViewController(withIdentifier: "config") as! ConfigViewController
            self.present(nextView, animated: false, completion: nil)
        }
    }
    
}
