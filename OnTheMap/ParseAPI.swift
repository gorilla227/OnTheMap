//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/12.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import Foundation

class ParseAPI: NSObject {
    
    // MARK: Properties
    var studentLocations: [StudentLocation]?
    var myLocation: StudentLocation?
    
    // MARK: Methods Functions
    
    func getStudentLocations(parameters: [String: AnyObject]?, completionHandler: (result: [StudentLocation]?, error: NSError?) -> Void) {
        let errorDomain = "getStudentLocations"
        
        // 1. Create Request
        let request = generateRequest(HTTPMethodType.GET, requestMethod: Constants.Methods.GETingStudentLocations, parameters: nil, httpBody: nil)
        
        // 2. Create Task
        let task = createDataTaskWithRequest(request, errorDomain: errorDomain) {(result, error) in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let results = (result as? [String: AnyObject])![Constants.ResponseKeys.Results] as? [[String: AnyObject]] else {
                completionHandler(result: nil, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Return incorrect JSON structure"]))
                return
            }
            
            var studentLocations = [StudentLocation]()
            for locationDictionary in results {
                let studentLocation = StudentLocation(dictionary: locationDictionary)
                studentLocations.append(studentLocation)
            }
            self.studentLocations = studentLocations
            completionHandler(result: studentLocations, error: nil)
        }
        
        // 3. Run Task
        task.resume()
    }
    
    func queryStudentLocation(uniqueKey: String, completionHandler: (result: StudentLocation?, error: NSError?) -> Void) {
        let errorDomain = "queryStudentLocation"
        
        // 1. Create Request
        let parameter = [Constants.ParameterKeys.Where: "{\"\(StudentLocation.ObjectKeys.UniqueKey)\":\"\(uniqueKey)\"}"]
        let request = generateRequest(HTTPMethodType.GET, requestMethod: Constants.Methods.QUERYingStudentLocation, parameters: parameter, httpBody: nil)
        
        // 2. Create Task
        let task = createDataTaskWithRequest(request, errorDomain: errorDomain) { (result, error) in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let results = (result as? [String: AnyObject])![Constants.ResponseKeys.Results] as? [[String: AnyObject]] else {
                completionHandler(result: nil, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Return incorrect JSON structure"]))
                return
            }
            
            if results.count == 1 {
                let studentLocationDictionary = results.first
                let studentLocation = StudentLocation(dictionary: studentLocationDictionary!)
                print(studentLocationDictionary)
                completionHandler(result: studentLocation, error: nil)
            } else {
                completionHandler(result: nil, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Not get correct student location"]))
            }
        }
        
        // 3. Run Task
        task.resume()
    }
    
    func addStudentLocation(parameters: [String: AnyObject], completionHandler: (success: Bool, error: NSError?) -> Void) {
        let errorDomain = "addStudentLocation"
        
        // 1. Create Request
        let httpBody: NSData?
        do {
            httpBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
        } catch {
            completionHandler(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize JSON data"]))
            return
        }
        
        let request = generateRequest(HTTPMethodType.POST, requestMethod: Constants.Methods.POSTingStudentLocation, parameters: nil, httpBody: httpBody)
        
        // 2. Create Task
        let task = createDataTaskWithRequest(request, errorDomain: errorDomain) { (result, error) in
            guard error == nil else {
                completionHandler(success: false, error: error)
                return
            }
            
            guard let result = result as? [String: AnyObject] else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Return incorrect JSON structure"]))
                return
            }
            
            var dictionary = parameters
            guard let createdAt = result[Constants.ResponseKeys.CreatedAt] as? String, let objectID = result[Constants.ResponseKeys.ObjectID] else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find CreatedAt and ObjectID in response"]))
                return
            }
            
            dictionary[StudentLocation.ObjectKeys.CreateAt] = createdAt
            dictionary[StudentLocation.ObjectKeys.ObjectID] = objectID
            let studentLocation = StudentLocation(dictionary: dictionary)
            self.myLocation = studentLocation
            
            completionHandler(success: true, error: nil)
        }
        
        // 3. Run Task
        task.resume()
    }
    
    func updateStudentLocation(parameters: [String: AnyObject], completionHandler: (success: Bool, error: NSError?) -> Void) {
        let errorDomain = "updateStudentLocation"
        
        // 1. Create Request
        let requestMethod = replacPlaceholder(Constants.Methods.PUTingStudentLocation, replacements: [Constants.ReplacementKeys.ObjectID: myLocation!.objectID])
        
        let httpBody: NSData?
        do {
            httpBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
        } catch {
            completionHandler(success: false, error: NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize JSON data"]))
            return
        }
        
        let request = generateRequest(HTTPMethodType.PUT, requestMethod: requestMethod, parameters: nil, httpBody: httpBody)
        
        // 2. Create Task
        let task = createDataTaskWithRequest(request, errorDomain: errorDomain) { (result, error) in
            guard error == nil else {
                completionHandler(success: false, error: error)
                return
            }
            
            guard let result = result as? [String: AnyObject] else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Return incorrect JSON structure"]))
                return
            }
            
            guard let updatedAt = result[Constants.ResponseKeys.UpdatedAt] as? String else {
                completionHandler(success: false, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find updatedAt in response"]))
                return
            }
            print("Update Result: \(result)")
            self.myLocation?.updatedAt = StudentLocation.dateFormatter.dateFromString(updatedAt)
            
            completionHandler(success: true, error: nil)
        }
        
        // 3. Run Task
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

// Private Functions
extension ParseAPI {
    private func desearializeJSONData(data: NSData) throws -> AnyObject? {
        do {
            let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            return result
        } catch {
            throw error
        }
    }
    
    private func generateRequest(httpMethod: HTTPMethodType, requestMethod: String, parameters: [String: AnyObject]?, httpBody: NSData?) -> NSMutableURLRequest {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = Constants.Base.Scheme
        urlComponents.host = Constants.Base.Host
        urlComponents.path = requestMethod
        
        if let parameters = parameters {
            urlComponents.queryItems = [NSURLQueryItem]()
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: value as? String)
                urlComponents.queryItems?.append(queryItem)
            }
        }
        
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
                let result = try self.desearializeJSONData(data)
                completionHandler(result: result, error: nil)
            } catch {
                completionHandler(result: nil, error: NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to deserialize JSON response"]))
                return
            }
        }
        return task
    }
}