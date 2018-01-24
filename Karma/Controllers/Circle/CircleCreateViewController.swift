//
//  CircleCreateViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/2/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CircleCreateViewController: CircleController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createCircle(sender : AnyObject) {
        if (validCircle()) {
            self.performSegue(withIdentifier: "CircleToMain", sender: self)
        }
    }
    
    // Server Call
    func validCircle() -> Bool {
        let backendless = Backendless.sharedInstance()!
        let dataStore = backendless.data.of(Circle().ofClass())
        
        let circle = Circle(name: circleNameField.text!)
        let currentUser = User.getCurrentUser()
        var valid = true
        
        Types.tryblock({ () -> Void in
            //Save the new object, retrieve its object id, and add the relation to the Users column
            let savedCircle = dataStore!.save(circle) as! Circle;
            dataStore!.setRelation(
                "Users",
                parentObjectId: savedCircle.objectId,
                childObjects: [currentUser.objectId]
            )
            currentUser.updateProperties(["circleId" : savedCircle.objectId!])
            backendless.userService.update(currentUser)
        }, catchblock: {(exception) -> Void in
            print(exception ?? "Error")
            valid = false
        })
        
        return valid
    }
}
