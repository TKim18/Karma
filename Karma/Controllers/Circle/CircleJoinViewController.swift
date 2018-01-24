//
//  CircleJoinViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 1/24/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit

class CircleJoinViewController: CircleController {

    @IBAction func joinCircle(sender : AnyObject) {
        if (self.validValues() && validCircle()) {
            self.performSegue(withIdentifier: "JoinCircle", sender: self)
        }
    }
    
    // Server Call
    override func validCircle() -> Bool {
//        let backendless = Backendless.sharedInstance()!
//        let dataStore = backendless.data.of(Circle().ofClass())
//
//        let circle = Circle(name: circleNameField.text!, password: circleKeyField.text!)
//        let currentUser = User.getCurrentUser()
//        var valid = true
//
//        Types.tryblock({ () -> Void in
//            //Save the new object, retrieve its object id, and add the relation to the Users column
//            let savedCircle = dataStore!.save(circle) as! Circle;
//            dataStore!.setRelation(
//                "Users",
//                parentObjectId: savedCircle.objectId,
//                childObjects: [currentUser.objectId]
//            )
//            currentUser.updateProperties(["circleId" : savedCircle.objectId!])
//            backendless.userService.update(currentUser)
//        }, catchblock: {(exception) -> Void in
//            print(exception ?? "Error")
//            valid = false
//        })
//
//       return valid
        return false
    }

}
