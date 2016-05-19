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
    
    // MARK: Properties
    var locationString: String?
    var location: CLLocationCoordinate2D?
    let udacity = UdacityAPI.sharedInstance()
    let parse = ParseAPI.sharedInstance()

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        findLocationAndAddToMap()
    }
    
    func findLocationAndAddToMap() {
        if let locationString = self.locationString {
            let localSearchRequest = MKLocalSearchRequest()
            localSearchRequest.naturalLanguageQuery = locationString
            let localSearch = MKLocalSearch(request: localSearchRequest)
            localSearch.startWithCompletionHandler({ (localSearchResponse, error) in
                guard error == nil else {
                    print("Search Location: \(error?.domain), \(error?.localizedDescription)")
                    return
                }
                
                if let localSearchResponse = localSearchResponse where localSearchResponse.mapItems.count > 0 {
                    let mapItem = localSearchResponse.mapItems.first
                    
                    if let location = mapItem?.placemark.coordinate {
                        self.location = location
                        let mapPin = MapPin(onlyLocation: location)
                        self.mapView.addAnnotation(mapPin)
                        
                        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        let coordinateRegion = MKCoordinateRegion(center: location, span: coordinateSpan)
                        self.mapView.setRegion(coordinateRegion, animated: true)
                    }
                    
                }
            })
            
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
            StudentLocation.ObjectKeys.Latitude: (location?.latitude)!,
            StudentLocation.ObjectKeys.Longitude: (location?.longitude)!
        ]
        
        print("Submit Parameters: \(parameters)")
        
        if parse.myLocation != nil {
            // Update Student Location
            parse.updateStudentLocation(parameters, completionHandler: { (success, error) in
                guard error == nil && success else {
                    print("Updated My Location error: \(error?.domain), \(error?.localizedDescription)")
                    return
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(MapPin.LocationAddedUpdatedNotification, object: nil)
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            })
        } else {
            // Add Student Location
            parse.addStudentLocation(parameters) { (success, error) in
                guard error == nil && success else {
                    print("Added My Location error: \(error?.domain), \(error?.localizedDescription)")
                    return
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(MapPin.LocationAddedUpdatedNotification, object: nil)
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
