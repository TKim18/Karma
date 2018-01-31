//
//  CircleController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CircleController: UIViewController {

    // UI Elements
    @IBOutlet var circleNameField : UITextField!
    @IBOutlet var circleKeyField: UITextField!
    let backendless = Backendless.sharedInstance()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func validValues() -> Bool {
        if (circleNameField.text!.isEmpty || circleKeyField.text!.isEmpty) {
            let (title, message) = circleNameField.text!.isEmpty ? ("Please enter a name", "e.g., League of Draven") : ("Please enter a key", "e.g., coolbeans123")
            let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
}
