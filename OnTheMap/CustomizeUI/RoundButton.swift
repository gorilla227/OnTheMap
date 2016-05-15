//
//  RoundButton.swift
//  OnTheMap
//
//  Created by Andy on 16/5/14.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit

class RoundButton: UIButton {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        // Drawing code
        layer.cornerRadius = rect.size.height / 5
        layer.masksToBounds = true
    }
}
