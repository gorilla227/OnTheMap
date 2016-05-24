//
//  AddMyLinkVC.swift
//  OnTheMap
//
//  Created by Andy on 16/5/15.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddMyLinkVC: UIViewController {
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: RoundButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    var locationString: String?
    var mapPin: MapPin?
    let udacity = UdacityAPI.sharedInstance()
    let parse = ParseAPI.sharedInstance()

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addMapPinToMap()
    }
    
    func addMapPinToMap() {
        if let mapPin = mapPin {
            mapView.addAnnotation(mapPin)
            
            let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let coordinateRegion = MKCoordinateRegion(center: mapPin.coordinate, span: coordinateSpan)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    // MARK: Private Fuctions
    private func showAlert(error: NSError?) {
        stopInteraction(false, runInBackground: true) {
            let alertView = UIAlertController(title: nil, message: error?.localizedDescription ?? "Unknown Error", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertView.addAction(cancelAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    private func setEnableUI(enable: Bool) {
        linkTextField.enabled = enable
        submitButton.enabled = enable
    }
    
    private func stopInteraction(shouldStop: Bool, runInBackground: Bool, completionHandler: (() -> Void)?) {
        func action(shouldStop: Bool) {
            
            if shouldStop {
                self.setEnableUI(false)
                self.activityIndicator.startAnimating()
            } else {
                self.setEnableUI(true)
                self.activityIndicator.stopAnimating()
            }
            if completionHandler != nil {
                completionHandler!()
            }
        }
        
        
        if runInBackground {
            performUIUpdatesOnMain {
                action(shouldStop)
            }
        } else {
            action(shouldStop)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func sumbitButtonOnClicked(sender: AnyObject) {
        let parameters: [String: AnyObject] = [
            StudentLocation.ObjectKeys.UniqueKey: udacity.accountID!,
            StudentLocation.ObjectKeys.FirstName: udacity.accountData![UdacityAPI.Constants.ResponseKeys.FirstName]!,
            StudentLocation.ObjectKeys.LastName: udacity.accountData![UdacityAPI.Constants.ResponseKeys.LastName]!,
            StudentLocation.ObjectKeys.MapString: locationString!,
            StudentLocation.ObjectKeys.MediaURL: linkTextField.text!,
            StudentLocation.ObjectKeys.Latitude: (mapPin?.coordinate.latitude)!,
            StudentLocation.ObjectKeys.Longitude: (mapPin?.coordinate.longitude)!
        ]
        
        print("Submit Parameters: \(parameters)")
        
        stopInteraction(true, runInBackground: false, completionHandler: nil)
        if parse.myLocation != nil {
            // Update Student Location
            parse.updateStudentLocation(parameters, completionHandler: { (success, error) in
                guard error == nil && success else {
                    print("Updated My Location error: \(error?.domain), \(error?.localizedDescription)")
                    self.showAlert(error)
                    return
                }
                
                self.stopInteraction(false, runInBackground: true, completionHandler: {
                    NSNotificationCenter.defaultCenter().postNotificationName(MapPin.LocationAddedUpdatedNotification, object: nil)
                    self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                })
                
            })
        } else {
            // Add Student Location
            parse.addStudentLocation(parameters) { (success, error) in
                guard error == nil && success else {
                    print("Added My Location error: \(error?.domain), \(error?.localizedDescription)")
                    self.showAlert(error)
                    return
                }
                
                self.stopInteraction(false, runInBackground: true, completionHandler: {
                    NSNotificationCenter.defaultCenter().postNotificationName(MapPin.LocationAddedUpdatedNotification, object: nil)
                    self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        }
    }

    @IBAction func cancelButtonOnClicked(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddMyLinkVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
