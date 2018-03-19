//
//  CircleCreateViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/2/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CircleCreateViewController: CircleController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
    }

    @IBAction func createCircle(sender : AnyObject) {
        if (self.validValues()) {
            createCircle()
        }
    }
    
    // Helper Function
    func notifyDuplicate() {
        let alert = UIAlertController(title: "Sorry, that name is taken", message: "Please choose an equally cool name!",  preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Server Call
    func createCircle() {
        activityIndicator.startAnimating()
        let circle = Circle(name: circleNameField.text!, password: circleKeyField.text!)
        if circle.exists() {
            notifyDuplicate()
        }
        else {
            // Update user object as well
            circle.upload()
            UserUtil.updateCurrentGroup(joinName: circleNameField.text!)
            //self.performSegue(withIdentifier: "CreateCircle", sender: self)
        }
        activityIndicator.stopAnimating()
    }
}
