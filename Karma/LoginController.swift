//
//  LoginController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    //Override functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UI Elements
    @IBOutlet var emailField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var errorMessage : UILabel!
    
    @IBAction func showRegister(sender : AnyObject) {
        self.performSegue(withIdentifier: "LoginToRegister", sender: nil)
    }
    
    @IBAction func loginButton(sender : AnyObject) {
        if (validLogin()) {
            let identifier = hasCircle() ? "LoginToMain" : "LoginNoCircle"
            self.performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
    //Segue handling
    func validLogin() -> Bool {
        return login(id: emailField.text!, password: passwordField.text!)
    }
    
    func hasCircle() -> Bool {
        let backendless = Backendless.sharedInstance()!
        let currentUser : BackendlessUser = backendless.userService.currentUser
        // "-1" is the default value
        return ((currentUser.getProperty("circleId") as! String) != "-1")
    }
    
    //Server call
    func login(id: String, password: String) -> Bool {
        let backendless = Backendless.sharedInstance()!
        
        var valid = true
        Types.tryblock({ () -> Void in
            backendless.userService.login(id, password: password)
        }, catchblock: {(exception) -> Void in
            let error = exception as! Fault
            self.errorMessage.text = error.message!
            valid = false
        })
        return valid
    }

}
