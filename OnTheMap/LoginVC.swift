//
//  LoginVC.swift
//  OnTheMap
//
//  Created by Andy Xu on 16/5/11.
//  Copyright © 2016年 Andy Xu. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginVC: UIViewController {
    @IBOutlet weak var emailTextField: SquareTextField!
    @IBOutlet weak var passwordTextField: SquareTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: RoundButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var mainStackView: UIStackView!
    
    let udacity = UdacityAPI.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            
            // Create Session with Facebook Authentication
            stopInteraction(true, runInBackground: false, completionHandler: nil)
            udacity.createSessionWithFacebookAuthentication(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (success, error) in
                guard error == nil && success else {
                    print(error?.domain, error?.localizedDescription)
                    self.showAlert(error)
                    
                    return
                }
                // Get Public User Data
                self.udacity.getPublicUserData(self.udacity.accountID!, completionHandler: { (result, error) in
                    
                    guard error == nil else {
                        print(error?.domain, error?.localizedDescription)
                        self.showAlert(error)
                        return
                    }
                    
                    self.stopInteraction(false, runInBackground: true, completionHandler: {
                        self.completeLogin()
                    })
                })
            })
        }
    }
    
    // MARK: Private Functions
    private func showAlert(error: NSError?) {
        stopInteraction(false, runInBackground: true) { 
            let alertView = UIAlertController(title: nil, message: error?.localizedDescription ?? "Unknown Error", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertView.addAction(cancelAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    private func completeLogin() {
        emailTextField.text = nil
        passwordTextField.text = nil
        performSegueWithIdentifier("CompleteLogin", sender: self)
    }
    
    private func setEnableUI(enable: Bool) {
        emailTextField.enabled = enable
        passwordTextField.enabled = enable
        loginButton.enabled = enable
        signUpButton.enabled = enable
        facebookLoginButton.enabled = enable
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
    
    // MARK: IBActions

    @IBAction func loginButtonOnClicked(sender: AnyObject) {
        stopInteraction(true, runInBackground: false, completionHandler: nil)
        
        // Create Session
        udacity.createSession(emailTextField.text!, password: passwordTextField.text!, completionHandler: { (success, error) in
            
            guard error == nil && success else {
                print(error?.domain, error?.localizedDescription)
                self.showAlert(error)
                return
            }

            // Get Public User Data
            self.udacity.getPublicUserData(self.udacity.accountID!, completionHandler: { (result, error) in
                
                guard error == nil else {
                    print(error?.domain, error?.localizedDescription)
                    self.showAlert(error)
                    return
                }
                
                self.stopInteraction(false, runInBackground: true, completionHandler: {
                    self.completeLogin()
                })
            })
        })
    }
    
    @IBAction func signUpButtonOnClicked(sender: AnyObject) {
        let signUpURL = NSURL(string: UdacityAPI.Constants.Base.SignUpURL)
        UIApplication.sharedApplication().openURL(signUpURL!)
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
}

extension LoginVC: FBSDKLoginButtonDelegate {
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if !result.isCancelled {
            stopInteraction(true, runInBackground: true, completionHandler: nil)
            if result.grantedPermissions.contains("email") {
                print(result.token.tokenString)
                // Create Session with Facebook Authentication
                self.udacity.createSessionWithFacebookAuthentication(result.token.tokenString, completionHandler: { (success, error) in
                    guard error == nil && success else {
                        print(error?.domain, error?.localizedDescription)
                        self.showAlert(error)
                        return
                    }
                    
                    // Get Public User Data
                    self.udacity.getPublicUserData(self.udacity.accountID!, completionHandler: { (result, error) in
                        
                        guard error == nil else {
                            print(error?.domain, error?.localizedDescription)
                            self.showAlert(error)
                            return
                        }
                        
                        self.stopInteraction(false, runInBackground: true, completionHandler: {
                            self.completeLogin()
                        })
                    })
                })
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        stopInteraction(true, runInBackground: false, completionHandler: nil)
        udacity.deleteSession { (result, error) in
            guard error == nil else {
                print(error?.domain, error?.localizedDescription)
                self.showAlert(error)
                return
            }
            
            self.stopInteraction(false, runInBackground: true, completionHandler: nil)
        }
    }
}