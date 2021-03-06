//
//  CircleJoinViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 1/24/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit

class CircleJoinViewController: CircleController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
    }
    
    @IBAction func joinCircle(sender : AnyObject) {
        if (self.validValues()) {
            joinCircle()
        }
    }

    // Server Call
    func joinCircle(){
        activityIndicator.startAnimating()
        let circle = Circle(name: circleNameField.text!, password: circleKeyField.text!)
        circle.existsWithKey() { exists in
            self.activityIndicator.stopAnimating()
            exists ? self.updateCircle(circle: circle) : self.alertNoExist()
        }
    }
    
    func updateCircle(circle: Circle) {
        circle.upload(newCircle: false) {
            self.performSegue(withIdentifier: "JoinCircle", sender: self)
        }
    }
    
    func alertNoExist() {
        let alert = UIAlertController(title: "Sorry, those are not valid credentials", message: "The key is case sensitive.",  preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }

}
