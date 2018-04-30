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
    @IBOutlet weak var emailField : UITextField!
    @IBOutlet weak var passwordField : UITextField!
    @IBOutlet weak var errorMessage : UILabel!
    @IBOutlet weak var wesleyan : UITextField!
    @IBOutlet weak var registerButton : UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        registerButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.activityIndicator.hidesWhenStopped = true
        self.wesleyan.text = Constants.User.wesleyan
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func loginButton(sender : AnyObject) {
        if let email = self.emailField.text, let password = self.passwordField.text {
            login(email: (email + Constants.User.wesleyan), password: password)
        }
        else {
            self.errorMessage.text = Constants.User.invalidLogin
        }
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
            UserUtil.getCurrentProperty(key: Constants.User.Fields.circles) { prop in
                let identifier = prop == nil ? Constants.Segue.ToNoCircle : Constants.Segue.LoginToMain
                self.performSegue(withIdentifier: identifier, sender: self)
            }
        }
    }
}
