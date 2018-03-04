//
//  LoginController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    // UI Elements
    @IBOutlet var emailField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var errorMessage : UILabel!
    @IBOutlet var registerButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLoggedIn()
    }
    
    private func checkLoggedIn() {
        let userService = Backendless.sharedInstance().userService
        if (userService?.isValidUserToken().boolValue)! {
            self.performSegue(withIdentifier: "LoginToTab", sender: self)
        }
    }
    
    private func setupView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        registerButton.titleLabel?.textAlignment = NSTextAlignment.center
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func showRegister(sender : AnyObject) {
        self.performSegue(withIdentifier: "LoginToRegister", sender: nil)
    }
    
    @IBAction func loginButton(sender : AnyObject) {
        if (validLogin()) {
            let identifier = hasCircle() ? "LoginToTab" : "LoginNoCircle"
            self.performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
    // Segue handling
    func validLogin() -> Bool {
        return login(id: emailField.text!, password: passwordField.text!)
    }
    
    func hasCircle() -> Bool {
        return ((User.getCurrentUserProperty(key: "circleId") as! String) != "-1")
    }
    
    // Server call
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
