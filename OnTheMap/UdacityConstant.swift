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
            static let Host = "udacity.com"
        }
        struct Methods {
            static let POSTingSession = "/api/session"
        }
        
        struct ParameterKeys {
            static let Udacity = "udacity"
            static let UserName = "username"
            static let Password = "password"
        }
        
        struct ResponseKeys {
            static let Account = "account"
            static let IsRegistered = "registered"
            static let Session = "session"
            static let SessionID = "id"
            static let SessionExpiration = "expiration"
        }
    }
    
    enum HTTPMethodType: String {
        case GET = "GET", POST = "POST", DELETE = "DELETE"
    }
}