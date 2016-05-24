//
//  AddMyPinVC.swift
//  OnTheMap
//
//  Created by Andy on 16/5/13.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit
import MapKit

class AddMyPinVC: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: RoundButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    func findLocationAndAddToMap() {
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationTextField.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        
        stopInteraction(true, runInBackground: false, completionHandler: nil)
        localSearch.startWithCompletionHandler({ (localSearchResponse, error) in
            guard error == nil else {
                print("Search Location: \(error?.domain), \(error?.localizedDescription)")
                self.showAlert(error)
                return
            }
            
            guard let localSearchResponse = localSearchResponse where localSearchResponse.mapItems.count > 0 else {
                self.showAlert(NSError(domain: "Find location", code: 1, userInfo: [NSLocalizedDescriptionKey: "No result found"]))
                return
            }
            
            self.stopInteraction(false, runInBackground: true, completionHandler: { 
                let mapItem = localSearchResponse.mapItems.first
                
                if let location = mapItem?.placemark.coordinate {
                    let mapPin = MapPin(onlyLocation: location)
                    
                    self.performSegueWithIdentifier("FindLocationAndAddLink", sender: mapPin)
                }
            })
        })
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
        locationTextField.enabled = enable
        findOnTheMapButton.enabled = enable
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
    
    // MARK: Keyboard adjustment
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        UIApplication.sharedApplication()
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
            return keyboardSize.CGRectValue().height
        } else {
            return 0
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // Move view to prevent keyboard covers textField
        let rectInMainView = locationTextField.convertRect(locationTextField.frame, toView: view)
        let moveDistance = max((getKeyboardHeight(notification) - (view.frame.size.height - rectInMainView.size.height - rectInMainView.origin.y)), 0)
        view.transform = CGAffineTransformMakeTranslation(0, -moveDistance)
    }
    
    func keyboardWillHidden(notification: NSNotification) {
        view.transform = CGAffineTransformMakeTranslation(0, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHidden), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: IBActions
    @IBAction func cancelButtonOnClicked(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func findOnTheMapButtonOnClicked(sender: AnyObject) {
        findLocationAndAddToMap()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FindLocationAndAddLink" {
            if let destVC = segue.destinationViewController as? AddMyLinkVC {
                destVC.locationString = locationTextField.text
                destVC.mapPin = sender as? MapPin
            }
        }
    }
}


extension AddMyPinVC: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text!).stringByReplacingCharactersInRange(range, withString: string)
        findOnTheMapButton.enabled = !newText.isEmpty
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}