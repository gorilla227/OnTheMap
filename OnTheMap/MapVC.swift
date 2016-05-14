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
        
    }
    
//    func cleanMapPins() {
//        mapView.removeAnnotations(mapView.annotations)
//    }
    
    func loadMapPin() {
        // Add new return annotations
        for studentLocation in parse.studentLocations! {
            performUIUpdatesOnMain({
                let annotation = MapPin(rawData: studentLocation)
                self.mapView.addAnnotation(annotation)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
