//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/11.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation

class UdacityAPI: NSObject {
    // MARK: Private Functions
    private func desearializeJSONData(data: NSData, completionHandler:(result: [String: AnyObject]?, error: NSError?) -> Void) {
        let prepareData: NSData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        do {
            let result = try NSJSONSerialization.JSONObjectWithData(prepareData, options: .AllowFragments) as! [String: AnyObject]
            completionHandler(result: result, error: nil)
        } catch {
            completionHandler(result: nil, error: NSError(domain: "createSession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to deserialize JSON response"]))
        }
    }
    
    private func generateRequest(httpMethod: HTTPMethodType, requestMethod: String, httpBody: NSData?) -> NSURLRequest {
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
            request.HTTPBody = httpBody
        default:
            break
        }
        return request
    }
    
    // MARK: Methods Functions
    func createSession(username: String, password: String, completionHandler:(result: [String: AnyObject]?, error: NSError?) -> Void) {
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
            completionHandler(result: nil, error: NSError(domain: "createSession", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize JSON data"]))
            return
        }
        
        let request = generateRequest(HTTPMethodType.POST, requestMethod: Constants.Methods.POSTingSession, httpBody: httpBody)
        
        // 2. Create Task
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                completionHandler(result: nil, error: NSError(domain: "createSession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Request returns error: \(error?.localizedDescription)"]))
                return
            }
            
            guard let statusCode: Int = (response as? NSHTTPURLResponse)!.statusCode where statusCode >= 200 && statusCode < 300 else {
                completionHandler(result: nil, error: NSError(domain: "createSession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Request returns un-successful StatusCode"]))
                return
            }
            
            guard let data = data else {
                completionHandler(result: nil, error: NSError(domain: "createSession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Return empty data"]))
                return
            }
            
            self.desearializeJSONData(data, completionHandler: completionHandler)
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