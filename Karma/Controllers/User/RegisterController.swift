//
//  RegisterController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterController: UIViewController {
    // UI Elements
    @IBOutlet var nameField : UITextField!
    @IBOutlet var emailField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var verifyField : UITextField!
    @IBOutlet var wesleyan : UITextField!
    @IBOutlet var errorMessage: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    private func setupView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.activityIndicator.hidesWhenStopped = true
        self.wesleyan.text = "@wesleyan.edu"
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Register button trigger
    @IBAction func registerButton(sender : AnyObject){
        if let email = self.emailField.text, let name = self.nameField.text, let password = self.passwordField.text {
            if self.validRegister() {
                register(email: email, name: name, password: password)
            }
        }
        else {
            self.errorMessage.text = "Please enter a valid email and password"
        }
    }
    
    // Validation
    func validRegister() -> Bool {
        if (passwordField.text != verifyField.text) {
            errorMessage.text = "Please verify that your password matches"
            return false
        }
        return true
    }
    
    // Server call
    // TODO: Upon register, add field of imagePath and name to user
    func register(email: String, name: String, password: String) {
        activityIndicator.startAnimating()
        Auth.auth().createUser(withEmail: (email + "@wesleyan.edu"), password: password) {
            (user, error) in
            if let error = error {
                self.errorMessage.text = error.localizedDescription
                return
            }
            self.activityIndicator.stopAnimating()
            self.performSegue(withIdentifier: "RegisterToCircle", sender: self)
        }
    }
}
