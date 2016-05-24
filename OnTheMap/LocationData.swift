//
//  LocationData.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/24.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation

class LocationData {
    // MARK: Properties
    
    var studentLocations: [StudentLocation]?
    var myLocation: StudentLocation?
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> LocationData {
        struct Singleton {
            static var sharedInstance = LocationData()
        }
        return Singleton.sharedInstance
    }
}