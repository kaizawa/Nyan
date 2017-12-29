//
//  TweetCell.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/07/05.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var mediaImage: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var userid: String?
    var tweet: [String:Any]?
    var retweeted = false
    
    override func prepareForReuse() {
        // アイコンをクリア
        icon.image = nil
        mediaImage.image = nil
    }
}
