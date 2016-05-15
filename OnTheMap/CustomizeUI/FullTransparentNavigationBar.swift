//
//  FullTransparentNavigationBar.swift
//  OnTheMap
//
//  Created by Andy on 16/5/13.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit

class FullTransparentNavigationBar: UINavigationBar {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Drawing code
        translucent = true
        setBackgroundImage(UIImage(), forBarMetrics: .Default)
        shadowImage = UIImage()
    }

}
