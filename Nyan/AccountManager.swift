//
//  AccountManager.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/04/30.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import Accounts

class AccountManager {
    
    static let sharedInstance = AccountManager()
    var accountStore:ACAccountStore = ACAccountStore()
    let semaphore = DispatchSemaphore(value: 1)
    var accounts:[ACAccount] = []
    var accountMap = [String:ACAccount]()

    private init() {

        requestAccounts()
    }
    
    func requestAccounts() {
    
        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        self.semaphore.wait()
        accounts.removeAll()

        self.accountStore.requestAccessToAccounts(with: accountType, options: nil) {
            
            (granted, error) -> Void in
            if error != nil {
                print(error!)
                self.semaphore.signal()
                return
            }
            
            if !granted {
                // access not granted
                self.semaphore.signal()
                return
            }
            
            self.accounts = self.accountStore.accounts(with: accountType) as! [ACAccount]
            if self.accounts.count == 0 {
                // no account
                self.semaphore.signal()
                return
            }
            for account in self.accounts {
                self.accountMap[account.username] = account
            }
            self.semaphore.signal()
        }
        // wait for account retrieval
        self.semaphore.wait()
        self.semaphore.signal()
    }
    
    func getAccount(name:String) ->ACAccount? {

        return accountMap[name]
    }
}
