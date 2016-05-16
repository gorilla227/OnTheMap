//
//  UdacityConstant.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/11.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation

extension UdacityAPI {
    struct Constants {
        struct Base {
            static let Scheme = "https"
            static let Host = "www.udacity.com"
            static let SignUpURL = "https://www.udacity.com/account/auth#!/signup"
        }
        struct Methods {
            static let POSTingSession = "/api/session"
            static let DELETEingSession = "/api/session"
            static let GETingPublicUserData = "/api/users/{\(ReplacementKeys.UserID)}"
        }
        
        struct ParameterKeys {
            static let Udacity = "udacity"
            static let UserName = "username"
            static let Password = "password"
        }
        
        struct ResponseKeys {
            static let Account = "account"
            static let IsRegistered = "registered"
            static let AccountKey = "key"
            static let Session = "session"
            static let SessionID = "id"
            static let SessionExpiration = "expiration"
            static let User = "user"
            static let FirstName = "first_name"
            static let LastName = "last_name"
        }
        
        struct ReplacementKeys {
            static let UserID = "user_id"
        }
        
        static let dateFormatter: NSDateFormatter = {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            return dateFormatter
        }()
    }
    
    enum HTTPMethodType: String {
        case GET = "GET", POST = "POST", DELETE = "DELETE"
    }
    
    
}