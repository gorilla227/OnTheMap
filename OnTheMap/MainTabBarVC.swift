//
//  MainTabBarVC.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/12.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class MainTabBarVC: UITabBarController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    let udacity = UdacityAPI.sharedInstance()
    let parse = ParseAPI.sharedInstance()
    let locationData = LocationData.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        // Request StudentLocations
        reloadMyLocation()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadMyLocation), name: MapPin.LocationAddedUpdatedNotification, object: nil)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reloadMyLocation() {
        let parameters: [String: AnyObject] = [
            ParseAPI.Constants.ParameterKeys.Order: "-" + StudentLocation.ObjectKeys.UpdatedAt,
            ParseAPI.Constants.ParameterKeys.Limit: "100"
        ]
        requestStudentLocations(parameters)
    }
    
    // MARK: Private Functions
    
    private func showAlert(error: NSError?) {
        activityIndicator.stopAnimating()
        let alertView = UIAlertController(title: nil, message: error?.localizedDescription ?? "Unknown Error", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(cancelAction)
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    private func requestStudentLocations(parameters: [String: AnyObject]?) {
        activityIndicator.startAnimating()
        parse.getStudentLocations(parameters) { (result, error) in
            guard error == nil else {
                print(error?.domain, error?.localizedDescription)
                self.showAlert(error)
                return
            }
            
            self.locationData.studentLocations = result
            self.queryMyLocation()
        }
    }
    
    private func queryMyLocation() {
        activityIndicator.startAnimating()
        parse.queryStudentLocation(udacity.accountID!) { (result, error) in
            guard error == nil else {
                print(error?.domain, error?.localizedDescription)
                self.showAlert(error)
                return
            }
            
            self.locationData.myLocation = result
            self.removeMyLocationFromList()
            self.loadMapPinsForSubViewControllers()
            performUIUpdatesOnMain({ 
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    private func loadMapPinsForSubViewControllers() {
        for viewController in self.viewControllers! {
            if let mapVC = viewController as? MapVC {
                mapVC.loadMapPin()
            } else if let listVC = viewController as? ListVC {
                listVC.tableView.reloadData()
            }
        }
    }
    
    private func removeMyLocationFromList() {
        if let myLocation = locationData.myLocation, var studentLocations = locationData.studentLocations {
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
        activityIndicator.startAnimating()
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKAccessToken.setCurrentAccessToken(nil)
            FBSDKProfile.setCurrentProfile(nil)
        }
        udacity.deleteSession { (result, error) in
            self.activityIndicator.stopAnimating()
            guard error == nil else {
                print(error?.domain, error?.localizedDescription)
                self.showAlert(error)
                return
            }
                
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func myPinButtonOnClicked(sender: AnyObject) {
        let SegueIdentifier = "CreateMyPin"
        
        print(locationData.myLocation)
        if locationData.myLocation == nil {
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
        reloadMyLocation()
    }

}