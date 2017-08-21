//
//  RegisterController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class RegisterController: UIViewController {

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
    @IBOutlet var nameField : UITextField!
    @IBOutlet var emailField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var verifyField : UITextField!
    @IBOutlet var errorMessage: UILabel!
    
    @IBAction func registerButton(sender : AnyObject){
        if (validRegister()) {
            self.performSegue(withIdentifier: "RegisterToCircle", sender: self)
        }
    }
    
    //Segue handling
    func validRegister() -> Bool {
        if (passwordField.text != verifyField.text) {
            errorMessage.text = "Please verify that your password matches"
            return false
        }
        else {
            return register(
                email: emailField.text!,
                name: nameField.text!,
                password: passwordField.text!
            )
        }
    }
    
    //Server call
    func register(email: String, name: String, password: String) -> Bool {
        let backendless = Backendless.sharedInstance()!
        let user = BackendlessUser()
        user.setProperty("email", object: email + "@wesleyan.edu")
        user.setProperty("name", object: name)
        user.setProperty("password", object: password)
        
        var valid = true
        Types.tryblock({ () -> Void in
            backendless.userService.register(user)
        },
        catchblock: { (exception) -> Void in
            let error = exception as! Fault
            self.errorMessage.text = error.message!
            valid = false
        })
        return valid
    }


}
