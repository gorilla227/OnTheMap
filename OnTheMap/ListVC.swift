//
//  ListVC.swift
//  OnTheMap
//
//  Created by Andy on 16/5/17.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit

class ListVC: UITableViewController {

    let parse = ParseAPI.sharedInstance()
    let locationData = LocationData.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let studentLocations = locationData.studentLocations {
            return studentLocations.count
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "ListCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)

        // Configure the cell...
        let cellData = locationData.studentLocations![indexPath.row]
        let name = cellData.firstName + " " + cellData.lastName

        cell.textLabel?.text = name
        
        print(cellData.updatedAt)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /* Switch to MapView and select annotation
        tabBarController?.selectedIndex = 0
        let mapVC = tabBarController?.viewControllers![0] as! MapVC
        let mapPins = mapVC.mapView.annotations as! [MapPin]
        let selectedMapPin = parse.studentLocations![indexPath.row]
        for mapPin in mapPins {
            if mapPin.studentLocation == selectedMapPin {
                mapVC.mapView.selectAnnotation(mapPin, animated: true)
                return
            }
        }
        */
        
        let selectedStudentLocation = locationData.studentLocations![indexPath.row]
        if var mediaURLString = selectedStudentLocation.mediaURL {
            if !mediaURLString.hasPrefix("http") {
                mediaURLString = "http://" + mediaURLString
            }
            if let mediaURL = NSURL(string: mediaURLString) {
                UIApplication.sharedApplication().openURL(mediaURL)
            }
        }
    }

}
