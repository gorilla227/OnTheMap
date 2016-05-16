//
//  MainTabBarVC.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/12.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit

class MainTabBarVC: UITabBarController {

    let udacity = UdacityAPI.sharedInstance()
    let parse = ParseAPI.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        requestStudentLocations(nil)
    }
    
    private func requestStudentLocations(parameters: [String: AnyObject]?) {
        parse.getStudentLocations(parameters) { (result, error) in
            guard error == nil else {
                print(error?.domain, error?.localizedDescription)
                return
            }
            
            self.queryMyLocation()
        }
    }
    
    private func queryMyLocation() {
        parse.queryStudentLocation(udacity.accountID!) { (result, error) in
            if error != nil {
                print(error?.domain, error?.localizedDescription)
            }
            
            self.parse.myLocation = result
            self.removeMyLocationFromList()
            self.loadMapPinsForSubViewControllers()
        }
    }
    
    private func loadMapPinsForSubViewControllers() {
        for viewController in self.viewControllers! {
            if let mapVC = viewController as? MapVC where viewController.isKindOfClass(MapVC) {
                mapVC.loadMapPin()
            }
        }
    }
    
    private func removeMyLocationFromList() {
        if let myLocation = parse.myLocation, var studentLocations = parse.studentLocations {
            for location in studentLocations {
                if location == myLocation {
                    studentLocations.removeAtIndex(studentLocations.indexOf(location)!)
                    return
                }
            }
        }
    }
    
    // MARK: IBActions

    @IBAction func logoutButtonOnClicked(sender: AnyObject) {
        udacity.deleteSession { (result, error) in
            guard error == nil else {
                print(error?.domain, error?.localizedDescription)
                return
            }
            
            if let sessionID = (result![UdacityAPI.Constants.ResponseKeys.Session] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.SessionID] as? String {
                print("Delete Session ID: \(sessionID)")
                self.udacity.sessionID = nil
                self.udacity.expirationDate = nil
                self.udacity.accountID = nil
                self.udacity.accountData = nil
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func myPinButtonOnClicked(sender: AnyObject) {
        let SegueIdentifier = "CreateMyPin"
        
        print(parse.myLocation)
        if parse.myLocation == nil {
            // Add myPin
            performSegueWithIdentifier(SegueIdentifier, sender: self)
        } else {
            // Create UIAlertController for overwrite
            let activityController = UIAlertController(title: nil, message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .Alert)
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default) { (action) in
                print("Overwrite")
                self.performSegueWithIdentifier(SegueIdentifier, sender: self)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                print("Cancel")
            }
            activityController.addAction(overwriteAction)
            activityController.addAction(cancelAction)
            
            presentViewController(activityController, animated: true, completion: nil)
        }
    }
    
    @IBAction func refreshMapPinsButtonOnClicked(sender: AnyObject) {
//        requestStudentLocations(nil)
    }

}