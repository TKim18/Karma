//
//  RegisterController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class RegisterController: UIViewController {
    // UI Elements
    @IBOutlet var nameField : UITextField!
    @IBOutlet var emailField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var verifyField : UITextField!
    @IBOutlet var wesleyan : UITextField!
    @IBOutlet var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    @IBAction func registerButton(sender : AnyObject){
        if (validRegister() && login()) {
            self.performSegue(withIdentifier: "RegisterToCircle", sender: self)
        }
    }
    
    private func setupView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.wesleyan.text = "@wesleyan.edu"
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Segue handling
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
    
    // Server call
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

    func login() -> Bool {
        let backendless = Backendless.sharedInstance()!
        
        var valid = true
        Types.tryblock({ () -> Void in
            backendless.userService.login(self.emailField.text! + "@wesleyan.edu", password: self.passwordField.text)
        }, catchblock: {(exception) -> Void in
            let error = exception as! Fault
            self.errorMessage.text = error.message!
            valid = false
        })
        return valid
    }
}
