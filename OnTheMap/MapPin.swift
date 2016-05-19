//
//  MapPin.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/13.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class MapPin: NSObject, MKAnnotation {
    static let LocationAddedUpdatedNotification = "LocationAddedUpdatedNotification"
    let studentLocation: StudentLocation?
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(rawData: StudentLocation) {
        studentLocation = rawData
        coordinate = rawData.location.coordinate
        title = rawData.firstName + " " + rawData.lastName
        subtitle = rawData.mediaURL
    }
    
    init(onlyLocation: CLLocationCoordinate2D) {
        coordinate = onlyLocation
        studentLocation = nil
        title = nil
        subtitle = nil
    }
}