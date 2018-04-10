//
//  CircleSettingsViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 4/9/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit

class CircleSettingsViewController: UIViewController {

    var initName : String!
    
    @IBOutlet weak var displayNameField : UITextField!
    @IBOutlet weak var joinKeyField : UITextField!
    @IBOutlet weak var newKeyField : UITextField!
    @IBOutlet weak var confirmKeyField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        setFields()
        
        listenFields()
    }
    
    private func setFields() {
        // Load in the current name
        Circle.getProperty(key: "displayName") { displayName in
            if let name = displayName as? String {
                self.displayNameField.text = name
                self.initName = name
            }
        }
    }
    
    private func setupView() {
        // Make a save button
        let barButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveCircleSettings))
        
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue], for: .normal)
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray], for: .disabled)
        
        barButtonItem.isEnabled = false
        navigationItem.setRightBarButton(barButtonItem, animated: false)
    }
    

    private func listenFields() {
        displayNameField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        joinKeyField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        newKeyField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        confirmKeyField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @IBAction func leaveCircle(sender: Any) {
        notify(title: "You can't leave", message: "lol")
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        guard let name = displayNameField.text, let joinKey = joinKeyField.text, let newKey = newKeyField.text, let confirmKey = confirmKeyField.text else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = (name != initName) || (joinKey != "") || (newKey != "") || (confirmKey != "")
    }
    
    @objc func saveCircleSettings() {
        if let newName = displayNameField!.text {
            if self.initName != newName {
                self.initName = newName
                Circle.setProperty(key: "displayName", value: newName)
                print("Changing display name")
            }
        } else {
            notify(title: "Sorry, that's not a valid name", message: "Please enter a real name")
        }
        
        if let joinKey = joinKeyField.text, let newKey = newKeyField.text, let confirmKey = confirmKeyField.text {
            // Check all three fields are entered
            if joinKey.isEmpty || newKey.isEmpty || confirmKey.isEmpty {
                notify(title: "Invalid Input", message: "Please enter all three key fields.")
                return
            }
            // Make sure new and confirm key match
            if newKey != confirmKey {
                notify(title: "Incorrect Confirm", message: "Make sure your new key and confirm key match.")
                return
            }
            // Check if the join key is correct
            Circle.getProperty(key: "joinKey") { prop in
                if let key = prop as? String {
                    if key != joinKey {
                        self.notify(title: "Incorrect Join Key", message: "Your join key is case and whitespace sensitive!")
                        return
                    } else {
                        Circle.setProperty(key: "joinKey", value: newKey)
                        self.notify(title: "Success!", message: "Your new join key has successfully been saved.")
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
