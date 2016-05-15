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
    @IBOutlet weak var loginButton: RoundButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var mainStackView: UIStackView!
    
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
    
    private func stopInteraction(shouldStop: Bool, runInBackground: Bool) {
        func action(shouldStop: Bool) {
            if shouldStop {
                self.setEnableUI(false)
                self.activityIndicator.startAnimating()
            } else {
                self.setEnableUI(true)
                self.activityIndicator.stopAnimating()
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

    @IBAction func loginButtonOnClicked(sender: AnyObject) {
        stopInteraction(true, runInBackground: false)
        
        // Create Session
        udacity.createSession("gorilla.andy@gmail.com", password: "gorilla8518", completionHandler: { (result, error) in
            self.stopInteraction(false, runInBackground: true)
            
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
                self.stopInteraction(true, runInBackground: false)
                
                // Get Public User Data
                self.udacity.getPublicUserData(accountKey, completionHandler: { (result, error) in
                    
                    guard error == nil else {
                        print(error?.domain, error?.localizedDescription)
                        self.stopInteraction(false, runInBackground: true)
                        
                        return
                    }
                    
                    if let result = result {
                        self.udacity.accountData = result
                        
                        self.completeLogin()
                    }
                    self.stopInteraction(false, runInBackground: true)
                })
            }
        })
    }
    
    @IBAction func signUpButtonOnClicked(sender: AnyObject) {
        
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
    
    func activedTextField() -> UITextField? {
        if emailTextField.isFirstResponder() {
            return emailTextField
        } else if passwordTextField.isFirstResponder() {
            return passwordTextField
        } else {
            return nil
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // Move view to prevent keyboard covers textField
        if let textField = activedTextField() {
            let rectInMainView = textField.convertRect(textField.frame, toView: mainStackView)
            let moveDistance = max((getKeyboardHeight(notification) - (mainStackView.frame.size.height - rectInMainView.size.height - rectInMainView.origin.y)), 0)
            mainStackView.transform = CGAffineTransformMakeTranslation(0, -moveDistance)
        }
    }
    
    func keyboardWillHidden(notification: NSNotification) {
        mainStackView.transform = CGAffineTransformMakeTranslation(0, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHidden), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
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

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
