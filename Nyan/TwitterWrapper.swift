//
//  TwitterWrapper.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/08/13.
//  Copyright © 2017年 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit
import Swifter

public typealias ErrorHandler = (String?) -> Void

class TwitterWrapper {
    
    static let sharedInstance = TwitterWrapper()
    let config:Config = Config.sharedInstance
    
    private var swifter = Swifter(
        consumerKey: "JVnDZmANHjkzU1Tx4awnXw6B0",
        consumerSecret: "bKYMHvYMXEDmCP1fYFmm3cY4Pegpm0QFsgEGY2dD4cZjCcmjUB"
    )
    
    static func getInstance() -> Swifter
    {
        return sharedInstance.swifter
    }

    private init ()
    {
        if let tokenKey = config.tokenKey, let tokenSecret = config.tokenSecret
        {
            let accessToken = Credential.OAuthAccessToken(key: tokenKey, secret: tokenSecret)
            let credential = Credential(accessToken: accessToken)
            swifter.client.credential = credential
        }
    }
}
