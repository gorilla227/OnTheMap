//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/11.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation

class UdacityAPI: NSObject {
    // MARK: Variables
    
    var sessionID: String?
    var accountID: String?
    var expirationDate: NSDate?
    var accountData: [String: AnyObject]?
    
    // MARK: Methods Functions
    
    func createSession(username: String, password: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        let errorDomain = "createSession"
        
        // 1. Create Request
        let parameters = [
            Constants.ParameterKeys.Udacity: [
                Constants.ParameterKeys.UserName: username,
                Constants.ParameterKeys.Password: password
            ]
        ]
        
        let httpBody: NSData?
        do {
            httpBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
        } catch {
            completionHandler(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize JSON data"]))
            return
        }
        
        let request = generateRequest(HTTPMethodType.POST, requestMethod: Constants.Methods.POSTingSession, httpBody: httpBody)
        
        // 2. Create Task
        let task = createDataTaskWithRequest(request, errorDomain: errorDomain) { (result, error) in
            guard error == nil else {
                completionHandler(success: false, error: error)
                return
            }
            
            guard let sessionID = (result![UdacityAPI.Constants.ResponseKeys.Session] as? [String: AnyObject])![Constants.ResponseKeys.SessionID] as? String else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find sessionID in response"]))
                return
            }
            self.sessionID = sessionID
            print("Session ID: \(sessionID)")
            
            guard let expirationDateString = (result![UdacityAPI.Constants.ResponseKeys.Session] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.SessionExpiration] as? String else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find expirationDate in response"]))
                return
            }
            
            guard let expirationDate = UdacityAPI.Constants.dateFormatter.dateFromString(expirationDateString) else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't transfer expirationDate from String to NSDate"]))
                return
            }
            self.expirationDate = expirationDate
            print("Expiration Date: \(expirationDate)")
            
            guard let accountKey = (result![UdacityAPI.Constants.ResponseKeys.Account] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.AccountKey] as? String else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find accountKey in response"]))
                return
            }
            self.accountID = accountKey
            print("Account Key: \(accountKey)")
            
            completionHandler(success: true, error: nil)
        }
        // 3. Run Task
        task.resume()
    }
    
    func createSessionWithFacebookAuthentication(facebookAccessToken: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        let errorDomain = "postSessionWithFacebookAuthentication"
        
        // 1. Create Request
        let parameters = [
            Constants.ParameterKeys.FacebookMobile: [
                Constants.ParameterKeys.FacebookAccessToken: facebookAccessToken
            ]
        ]
        print(facebookAccessToken)
        
        let httpBody: NSData?
        do {
            httpBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
        } catch {
            completionHandler(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize JSON data"]))
            return
        }
        
        let request = generateRequest(HTTPMethodType.POST, requestMethod: Constants.Methods.POSTingSessionWithFacebookAuthentication, httpBody: httpBody)
        
        // 2. Create Task
        let task = createDataTaskWithRequest(request, errorDomain: errorDomain) { (result, error) in
            guard error == nil else {
                completionHandler(success: false, error: error)
                return
            }
            
            guard let sessionID = (result![UdacityAPI.Constants.ResponseKeys.Session] as? [String: AnyObject])![Constants.ResponseKeys.SessionID] as? String else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find sessionID in response"]))
                return
            }
            self.sessionID = sessionID
            print("Session ID: \(sessionID)")
            
            guard let expirationDateString = (result![UdacityAPI.Constants.ResponseKeys.Session] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.SessionExpiration] as? String else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find expirationDate in response"]))
                return
            }
            
            guard let expirationDate = UdacityAPI.Constants.dateFormatter.dateFromString(expirationDateString) else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't transfer expirationDate from String to NSDate"]))
                return
            }
            self.expirationDate = expirationDate
            print("Expiration Date: \(expirationDate)")
            
            guard let accountKey = (result![UdacityAPI.Constants.ResponseKeys.Account] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.AccountKey] as? String else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find accountKey in response"]))
                return
            }
            self.accountID = accountKey
            print("Account Key: \(accountKey)")
            
            completionHandler(success: true, error: nil)
        }
        
        // 3. Run Task
        task.resume()
    }
    
    func deleteSession(completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void) {
        let errorDomain = "deleteSession"
        
        // 1. Create Request
        let request = generateRequest(HTTPMethodType.DELETE, requestMethod: Constants.Methods.DELETEingSession, httpBody: nil) 
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
                break
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // 2. Create Task
        let task = createDataTaskWithRequest(request, errorDomain: errorDomain) { (result, error) in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let sessionID = (result![Constants.ResponseKeys.Session] as? [String: AnyObject])![Constants.ResponseKeys.SessionID] as? String else {
                completionHandler(result: nil, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find sessionID in response"]))
                return
            }
            
            print("Delete Session ID: \(sessionID)")
            self.sessionID = nil
            self.expirationDate = nil
            self.accountID = nil
            self.accountData = nil
            
            completionHandler(result: [Constants.ResponseKeys.SessionID: sessionID], error: nil)
        }
        
        // 3. Run Task
        task.resume()
    }
    
    func getPublicUserData(userID: String, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void) {
        let errorDomain = "getPublicUserData"
        
        // 1. Create Request
        let requestMethod = replacPlaceholder(Constants.Methods.GETingPublicUserData, replacements: [Constants.ReplacementKeys.UserID: userID])
        let request = generateRequest(HTTPMethodType.GET, requestMethod: requestMethod, httpBody: nil)
        
        // 2. Create Task
        let task = createDataTaskWithRequest(request, errorDomain: errorDomain) { (result, error) in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            if let result = result![UdacityAPI.Constants.ResponseKeys.User] as? [String: AnyObject] {
                self.accountData = result
                
                completionHandler(result: result, error: nil)
            }
        }
        
        // 3. Run Task
        task.resume()
    }
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityAPI {
        struct Singleton {
            static var sharedInstance = UdacityAPI()
        }
        return Singleton.sharedInstance
    }
}


// MARK: Private Functions
extension UdacityAPI {
    private func desearializeJSONData(data: NSData) throws -> AnyObject? {
        let prepareData: NSData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        do {
            let result = try NSJSONSerialization.JSONObjectWithData(prepareData, options: .AllowFragments)
            return result
        } catch {
            throw error
        }
    }
    
    private func generateRequest(httpMethod: HTTPMethodType, requestMethod: String, httpBody: NSData?) -> NSMutableURLRequest {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = Constants.Base.Scheme
        urlComponents.host = Constants.Base.Host
        urlComponents.path = requestMethod
        let request = NSMutableURLRequest(URL: urlComponents.URL!)
        request.HTTPMethod = httpMethod.rawValue
        
        switch httpMethod {
        case .POST:
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let httpBody = httpBody {
                request.HTTPBody = httpBody
            }
        default:
            break
        }
        return request
    }
    
    private func replacPlaceholder(sourceString: String, replacements: [String: String]) -> String {
        var targetString = String(sourceString)
        for (replacementKey, replacementValue) in replacements {
            targetString = targetString.stringByReplacingOccurrencesOfString("{\(replacementKey)}", withString: replacementValue)
        }
        return targetString
    }
    
    private func createDataTaskWithRequest(request: NSURLRequest, errorDomain: String, completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                completionHandler(result: nil, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Request returns error: \(error?.localizedDescription)"]))
                return
            }
            
            guard let statusCode: Int = (response as? NSHTTPURLResponse)!.statusCode where statusCode >= 200 && statusCode < 300 else {
                completionHandler(result: nil, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Request returns un-successful StatusCode"]))
                return
            }
            
            guard let data = data else {
                completionHandler(result: nil, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Return empty data"]))
                return
            }
            
            // Take care response data
            do {
                let result = try self.desearializeJSONData(data) as! [String: AnyObject]
                completionHandler(result: result, error: nil)
            } catch {
                completionHandler(result: nil, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to deserialize JSON response"]))
                return
            }
        }
        return task
    }
}