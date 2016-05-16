//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/13.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation
import CoreLocation

struct StudentLocation {
    // MARK: Properties
    let objectID: String
    let uniqueKey: String?
    let firstName: String
    let lastName: String
    let mapString: String?
    let mediaURL: String?
    let location: CLLocation
    let createdAt: NSDate
    let updatedAt: NSDate?
    let acl: AnyObject?
    
    let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }()
    
    // MARK: Initializers
    init(dictionary: [String: AnyObject]) {
        objectID = dictionary[ObjectKeys.ObjectID] as! String
        uniqueKey = dictionary[ObjectKeys.UniqueKey] as? String
        firstName = dictionary[ObjectKeys.FirstName] as! String
        lastName = dictionary[ObjectKeys.LastName] as! String
        mapString = dictionary[ObjectKeys.MapString] as? String
        mediaURL = dictionary[ObjectKeys.MediaURL] as? String
        location = CLLocation(latitude: dictionary[ObjectKeys.Latitude] as! Double, longitude: dictionary[ObjectKeys.Longitude] as! Double)
        
        createdAt = dateFormatter.dateFromString(dictionary[ObjectKeys.CreateAt] as! String)!
        if let updatedAtString = dictionary[ObjectKeys.UpdatedAt] as? String {
            if let updateDate = dateFormatter.dateFromString(updatedAtString) {
                updatedAt = updateDate
            } else {
                updatedAt = nil
            }
        } else {
            updatedAt = nil
        }
        acl = dictionary[ObjectKeys.ACL]
    }
    
    struct ObjectKeys {
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreateAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        static let ACL = "ACL"
    }
}

// MARK: StudentLocation Equatable
extension StudentLocation: Equatable {}

func ==(lhs: StudentLocation, rhs: StudentLocation) -> Bool {
    return lhs.objectID == rhs.objectID
}