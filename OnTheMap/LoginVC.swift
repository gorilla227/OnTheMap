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
    
    let udacity = UdacityAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    

    @IBAction func loginButtonOnClicked(sender: AnyObject) {
        udacity.createSession("gorilla.andy@gmail.com", password: "gorilla8518", completionHandler: { (result, error) in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            print((result![UdacityAPI.Constants.ResponseKeys.Session] as? [String: AnyObject])![UdacityAPI.Constants.ResponseKeys.SessionID])
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
