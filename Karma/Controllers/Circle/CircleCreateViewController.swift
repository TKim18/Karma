//
//  CircleCreateViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/2/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CircleCreateViewController: CircleController {

    @IBAction func createCircle(sender : AnyObject) {
        if (self.validValues() && validCircle()) {
            self.performSegue(withIdentifier: "CreateCircle", sender: self)
        }
    }
    
    // Helper Function
    func alertExistDup() {
        let alert = UIAlertController(title: "Sorry, that name is taken", message: "Please choose an equally cool name!",  preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Server Call
    override func validCircle() -> Bool {
        let dataStore = self.backendless.data.of(Circle().ofClass())
        
        let circle = Circle(name: circleNameField.text!, password: circleKeyField.text!)
        let currentUser = User.getCurrentUser()
        var valid = true
        
        Types.tryblock({ () -> Void in
            //Save the new object, retrieve its object id, and add the relation to the Users column
            let savedCircle = dataStore!.save(circle) as! Circle
            dataStore!.setRelation(
                "Users",
                parentObjectId: savedCircle.objectId,
                childObjects: [currentUser.objectId]
            )
            currentUser.updateProperties(["circleId" : savedCircle.objectId!])
            self.backendless.userService.update(currentUser)
        }, catchblock: {(exception) -> Void in
            self.alertExistDup()
            print(exception ?? "Error")
            valid = false
        })
        
        return valid
    }
}
