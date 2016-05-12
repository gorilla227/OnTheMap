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
    
    let udacity = UdacityAPI.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func completeLogin() {
        performSegueWithIdentifier("CompleteLogin", sender: self)
    }
    

    @IBAction func loginButtonOnClicked(sender: AnyObject) {
        udacity.createSession("gorilla.andy@gmail.com", password: "gorilla8518", completionHandler: { (result, error) in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            if let sessionID = (result![UdacityAPI.Constants.ResponseKeys.Session] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.SessionID] as? String {
                self.udacity.sessionID = sessionID
            }
            
            if let accountKey = (result![UdacityAPI.Constants.ResponseKeys.Account] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.AccountKey] as? String {
                self.udacity.accountID = accountKey
            }
            
            if let expirationDate = (result![UdacityAPI.Constants.ResponseKeys.Session] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.SessionExpiration] as? String {
                
                if let expirationDate = UdacityAPI.Constants.dateFormatter.dateFromString(expirationDate) {
                    self.udacity.expirationDate = expirationDate
                }
            }
            
            print("Session ID: \(self.udacity.sessionID)")
            print("Account Key: \(self.udacity.accountID)")
            print("Expiration Date: \(self.udacity.expirationDate)")
            
            self.completeLogin()
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
