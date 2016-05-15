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
    let parse = ParseAPI.sharedInstance()

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        findLocationAndAddToMap()
    }
    
    func findLocationAndAddToMap() {
        print(locationString)
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
    }

    @IBAction func cancelButtonOnClicked(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
