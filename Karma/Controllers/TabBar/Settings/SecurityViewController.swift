//
//  SecurityViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 4/8/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseAuth

class SecurityViewController: UIViewController {

    @IBOutlet weak var currentPasswordField : UITextField!
    @IBOutlet weak var newPasswordField : UITextField!
    @IBOutlet weak var confirmPasswordField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        listenFields()
    }
    
    private func setupView() {
        // Make a save button
        let barButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveSecuritySettings))
        
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue], for: .normal)
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray], for: .disabled)
        
        barButtonItem.isEnabled = false
        navigationItem.setRightBarButton(barButtonItem, animated: false)
    }
    
    private func listenFields() {
        currentPasswordField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        newPasswordField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        guard let password = currentPasswordField.text, let newPass = newPasswordField.text, let confPass = confirmPasswordField.text else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = (password != "") || (newPass != "") || (confPass != "")
    }
    
    @objc func saveSecuritySettings() {
        if let currPass = currentPasswordField.text, let newPass = newPasswordField.text, let confirmPass = confirmPasswordField.text {
            // Check all three fields are entered
            if currPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty {
                notify(title: "Invalid Input", message: "Please enter all three password fields.")
                return
            }
            // Make sure new and confirm passwords match
            if newPass != confirmPass {
                notify(title: "Incorrect Confirm", message: "Make sure your new and confirm passwords match.")
                return
            }
            
            // Confirm the password is real
            let email = UserUtil.getCurrentEmail()!
            Auth.auth().signIn(withEmail: email, password: currPass) { (user, error) in
                if let _ = error {
                    self.notify(title: "Incorrect Password", message: "Make sure you typed in the correct password.")
                    return
                }
                UserUtil.getCurrentUser().updatePassword(to: newPass) { (error) in
                    if let _ = error {
                        self.notify(title: "Something went wrong", message: "Unable to change your password.")
                        return
                    } else {
                        self.notify(title: "Success!", message: "Your password has been changed.")
                    }
                }
            }
        }
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func notify(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
}

