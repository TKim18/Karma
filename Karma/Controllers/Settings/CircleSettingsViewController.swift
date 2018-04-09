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

        // Load in the current name
        Circle.getProperty(key: "displayName") { displayName in
            if let name = displayName as? String {
                self.displayNameField.text = name
                self.initName = name
            }
        }
        
        // Make a save button
        let barButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveCircleSettings))
        
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue], for: .normal)
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray], for: .disabled)
        
        barButtonItem.isEnabled = false
        navigationItem.setRightBarButton(barButtonItem, animated: false)
        
        listenFields()
    }

    private func listenFields() {
        displayNameField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        guard let name = displayNameField.text else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = (name != initName)
    }
    
    @objc func saveCircleSettings() {
        if let newName = displayNameField!.text {
            self.initName = newName
            Circle.setProperty(key: "displayName", value: newName)
        } else {
            let alert = UIAlertController(title: "Sorry, that's not a valid name", message: "Please enter a real name",  preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
}
