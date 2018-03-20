//
//  LoginController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    // UI Elements
    @IBOutlet var emailField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var errorMessage : UILabel!
    @IBOutlet var wesleyan : UITextField!
    @IBOutlet var registerButton : UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        registerButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.activityIndicator.hidesWhenStopped = true
        self.wesleyan.text = "@wesleyan.edu"
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func showRegister(sender : AnyObject) {
        self.performSegue(withIdentifier: "LoginToRegister", sender: nil)
    }
    
    //
    @IBAction func loginButton(sender : AnyObject) {
        if let email = self.emailField.text, let password = self.passwordField.text {
            login(email: (email + "@wesleyan.edu"), password: password)
        }
        else {
            self.errorMessage.text = "Please enter a valid email and password"
        }
    }
    
    func hasCircle() -> Bool {
        return ((UserUtil.getCurrentUserProperty(key: "circleId") as! String) != "-1")
    }
    
    // Server call
    func login(email: String, password: String) {
        activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) {
            (user, error) in
            self.activityIndicator.stopAnimating()
            if let error = error {
                self.errorMessage.text = error.localizedDescription
                return
            }
            UserUtil.getCurrentProperty(key: "circles") { prop in
                let identifier = prop == nil ? "LoginNoCircle" : "LoginToTab"
                self.performSegue(withIdentifier: identifier, sender: self)
            }
        }
    }
}
