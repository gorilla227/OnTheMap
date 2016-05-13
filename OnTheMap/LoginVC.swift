//
//  LoginVC.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/11.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    @IBOutlet weak var emailTextField: SquareTextField!
    @IBOutlet weak var passwordTextField: SquareTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    let udacity = UdacityAPI.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func completeLogin() {
        performSegueWithIdentifier("CompleteLogin", sender: self)
    }
    
    func setEnableUI(enable: Bool) {
        emailTextField.enabled = enable
        passwordTextField.enabled = enable
        loginButton.enabled = enable
        signUpButton.enabled = enable
        facebookLoginButton.enabled = enable
    }

    @IBAction func loginButtonOnClicked(sender: AnyObject) {
        setEnableUI(false)
        activityIndicator.startAnimating()
        
        // Create Session
        udacity.createSession("gorilla.andy@gmail.com", password: "gorilla8518", completionHandler: { (result, error) in
            performUIUpdatesOnMain({ 
                self.activityIndicator.stopAnimating()
            })
            
            guard error == nil else {
                print(error?.domain, error?.localizedDescription)
                return
            }
            
            if let sessionID = (result![UdacityAPI.Constants.ResponseKeys.Session] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.SessionID] as? String {
                self.udacity.sessionID = sessionID
                print("Session ID: \(self.udacity.sessionID)")
            }
            
            if let expirationDate = (result![UdacityAPI.Constants.ResponseKeys.Session] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.SessionExpiration] as? String {
                
                if let expirationDate = UdacityAPI.Constants.dateFormatter.dateFromString(expirationDate) {
                    self.udacity.expirationDate = expirationDate
                    print("Expiration Date: \(self.udacity.expirationDate)")
                }
            }
            
            if let accountKey = (result![UdacityAPI.Constants.ResponseKeys.Account] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.AccountKey] as? String {
                self.udacity.accountID = accountKey
                print("Account Key: \(self.udacity.accountID)")
                performUIUpdatesOnMain({
                    self.activityIndicator.startAnimating()
                })
                
                // Get Public User Data
                self.udacity.getPublicUserData(accountKey, completionHandler: { (result, error) in
                    
                    guard error == nil else {
                        print(error?.domain, error?.localizedDescription)
                        performUIUpdatesOnMain({
                            self.activityIndicator.stopAnimating()
                        })
                        return
                    }
                    
                    if let result = result {
                        self.udacity.accountData = result
                        
                        self.completeLogin()
                    }
                    performUIUpdatesOnMain({
                        self.activityIndicator.stopAnimating()
                    })
                })
            }
        })
    }
    
    @IBAction func signUpButtonOnClicked(sender: AnyObject) {
        
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
