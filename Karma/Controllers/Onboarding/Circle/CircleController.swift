//
//  CircleController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseAuth

class CircleController: UIViewController {

    // UI Elements
    @IBOutlet weak var circleNameField : UITextField!
    @IBOutlet weak var circleKeyField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CircleController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func validValues() -> Bool {
        if let _ = circleNameField.text, let _ = circleKeyField.text {
            return true
        }
        else {
            let (title, message) = circleNameField.text!.isEmpty ? ("Please enter a name", "e.g., League of Draven") : ("Please enter a key", "e.g., coolbeans123")
            let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
}
