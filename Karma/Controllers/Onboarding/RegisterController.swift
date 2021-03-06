//
//  RegisterController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import Firebase

class RegisterController: UIViewController {
    // UI Elements
    @IBOutlet weak var nameField : UITextField!
    @IBOutlet weak var emailField : UITextField!
    @IBOutlet weak var numberField : UITextField!
    @IBOutlet weak var passwordField : UITextField!
    @IBOutlet weak var verifyField : UITextField!
    @IBOutlet weak var wesleyan : UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    private func setupView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.activityIndicator.hidesWhenStopped = true
        self.wesleyan.text = Constants.User.wesleyan
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Register button trigger
    @IBAction func registerButton(sender : AnyObject){
        if let email = self.emailField.text, let name = self.nameField.text, let password = self.passwordField.text, let number = self.numberField.text {
            if self.validRegister() {
                register(email: email, name: name, password: password, number: number)
            }
        }
        else {
            self.errorMessage.text = Constants.User.invalidLogin
        }
    }
    
    // Validation
    func validRegister() -> Bool {
        if (passwordField.text != verifyField.text) {
            errorMessage.text = Constants.User.invalidPassword
            return false
        }
        if (nameField.text == "") {
            errorMessage.text = "Please enter a name"
            return false
        }
        return true
    }
    
    // Server call
    func register(email: String, name: String, password: String, number: String) {
        activityIndicator.startAnimating()
        Auth.auth().createUser(withEmail: (email + Constants.User.wesleyan), password: password) {
            (user, error) in
            self.activityIndicator.stopAnimating()
            if let error = error {
                self.errorMessage.text = error.localizedDescription
                return
            }
            if let user = user {
                self.ref.child("users").child(user.uid).setValue(
                    [Constants.User.Fields.name: name,
                     Constants.User.Fields.userName: email,
                     Constants.User.Fields.home: Constants.User.university,
                     Constants.User.Fields.points: Constants.User.initialPoints,
                     "phoneNumber" : number,
                     "photoURL": "default"]
                )
                Messaging.messaging().subscribe(toTopic: "\(email)")
                self.performSegue(withIdentifier: Constants.Segue.RegisterToMain, sender: self)
            }
        }
    }
}
