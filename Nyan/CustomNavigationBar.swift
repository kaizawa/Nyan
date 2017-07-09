//
//  CustomNavigationBar.swift
//  Nyan
//
//  Created by Kazuyoshi Aizawa on 2017/07/09.
//  Copyright © 2017 Kazuyoshi Aizawa. All rights reserved.
//

import Foundation
import UIKit

class CustomNavigationBar: UINavigationBar {
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        let prevSize:CGSize = super.sizeThatFits(size)
        let newSize:CGSize = CGSize(width: prevSize.width, height: 80)
        return newSize
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view: UIView in self.subviews {
            

            if(NSStringFromClass(type(of: view)) == "UINavigationItem") {

                view.frame.origin.y = view.frame.origin.y + 15;
            }
        }
    }
    
}
