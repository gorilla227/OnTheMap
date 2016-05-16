//
//  ParseConstant.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/12.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation

extension ParseAPI {
    
    struct Constants {
        struct Base {
            static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
            
            static let Scheme = "https"
            static let Host = "api.parse.com"
        }
        
        struct Methods {
            static let GETingStudentLocations = "/1/classes/StudentLocation"
            static let POSTingStudentLocation = "/1/classes/StudentLocation"
            static let QUERYingStudentLocation = "/1/classes/StudentLocation"
            static let PUTingStudentLocation = "/1/classes/StudentLocation/{\(ReplacementKeys.ObjectID)}"
        }
        
        struct ParameterKeys {
            static let Limit = "limit"
            static let Skip = "skip"
            static let Order = "order"
            static let Where = "where"
            static let ObjectID = "objectId"
        }
        
        struct ResponseKeys {
            static let Results = "results"
            static let CreatedAt = "createdAt"
            static let ObjectID = "objectId"
        }
        
        struct ReplacementKeys {
            static let ObjectID = "objectId"
        }
    }
    
    enum HTTPMethodType: String {
        case GET = "GET", POST = "POST", DELETE = "DELETE"
    }
}