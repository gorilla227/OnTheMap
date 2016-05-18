//
//  MapVC.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/12.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapVC: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    let udacity = UdacityAPI.sharedInstance()
    let parse = ParseAPI.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadMyLocation), name: "", object: nil)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func cleanMapPins() {
        performUIUpdatesOnMain { 
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }
    
    func loadMapPin() {
        cleanMapPins()
        // Add new return annotations
        for studentLocation in parse.studentLocations! {
            performUIUpdatesOnMain({
                let annotation = MapPin(rawData: studentLocation)
                self.mapView.addAnnotation(annotation)
            })
        }
        
        // Add User's annotation
        if let myLocation = parse.myLocation {
            performUIUpdatesOnMain({ 
                let annotation = MapPin(rawData: myLocation)
                self.mapView.addAnnotation(annotation)
            })
        }
    }
    
    func reloadMyLocation() {
        if let myLocation = parse.myLocation {
            for annotation in mapView.annotations {
                if let mapPin = annotation as? MapPin {
                    if mapPin.studentLocation == myLocation {
                        performUIUpdatesOnMain({ 
                            self.mapView.removeAnnotation(mapPin)
                        })
                        break
                    }
                }
            }
            performUIUpdatesOnMain({
                self.mapView.addAnnotation(MapPin(rawData: myLocation))
            })
        }
    }
    
    // MARK: MKMapViewDelegate Protocol
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let Identifier = "MapPin"
        if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(Identifier) {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Identifier)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            return annotationView
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if var mediaURLString = view.annotation?.subtitle {
            if !(mediaURLString?.hasPrefix("http"))! {
                mediaURLString = "http://" + mediaURLString!
            }
            if let mediaURL = NSURL(string: mediaURLString!) {
                UIApplication.sharedApplication().openURL(mediaURL)
            }
        }
    }
    
    @IBAction func debugButtonOnClicked(sender: AnyObject) {
        print(mapView.annotations.count)
    }

}
