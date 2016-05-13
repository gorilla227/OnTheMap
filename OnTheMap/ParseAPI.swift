//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/12.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation

class ParseAPI: NSObject {
    
    // MARK: Private Functions
    
    private func desearializeJSONData(data: NSData) throws -> AnyObject? {
        do {
            let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
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
        request.addValue(Constants.Base.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.Base.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
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
    
    // MARK: Methods Functions
    
    func getStudentLocations(parameters: [String: AnyObject]?, completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        let errorDomain = "getStudentLocations"
        
        // 1. Create Request
        let request = generateRequest(HTTPMethodType.GET, requestMethod: Constants.Methods.GETingStudentLocations, httpBody: nil)
        
        // 2. Create Task
        let task = self.createDataTaskWithRequest(request, errorDomain: errorDomain, completionHandler: completionHandler)
        
        //3. Run Task
        task.resume()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseAPI {
        struct Singleton {
            static var sharedInstance = ParseAPI()
        }
        return Singleton.sharedInstance
    }
}