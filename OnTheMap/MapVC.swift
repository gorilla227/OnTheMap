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
    
    let parse = ParseAPI.sharedInstance()
    let locationData = LocationData.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadMyLocation), name: MapPin.LocationAddedUpdatedNotification, object: nil)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func cleanMapPins() {
        performUIUpdatesOnMain({
            self.mapView.removeAnnotations(self.mapView.annotations)
        })
    }
    
    func loadMapPin() {
        cleanMapPins()
        // Add new return annotations
        for studentLocation in locationData.studentLocations! {
            performUIUpdatesOnMain({
                let annotation = MapPin(rawData: studentLocation)
                self.mapView.addAnnotation(annotation)
            })
        }
        
        // Add User's annotation
        if let myLocation = locationData.myLocation {
            performUIUpdatesOnMain({ 
                let annotation = MapPin(rawData: myLocation)
                self.mapView.addAnnotation(annotation)
                self.mapView.selectAnnotation(annotation, animated: true)
            })
        }
    }
    
    func reloadMyLocation() {
        if let myLocation = locationData.myLocation {
            for annotation in mapView.annotations {
                if let mapPin = annotation as? MapPin {
                    if mapPin.studentLocation == myLocation {
                        performUIUpdatesOnMain({
                            self.mapView.removeAnnotation(mapPin)
                        })
                    }
                }
            }
            performUIUpdatesOnMain({
                let myLocationAnnotation = MapPin(rawData: myLocation)
                self.mapView.addAnnotation(myLocationAnnotation)
                self.mapView.selectAnnotation(myLocationAnnotation, animated: true)
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
}
