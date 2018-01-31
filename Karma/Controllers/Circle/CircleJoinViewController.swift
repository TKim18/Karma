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
        if (self.validValues()) {
            self.joinCircle()
        }
    }
    
    // Helper Function
    func alertNoExist() {
        let alert = UIAlertController(title: "Sorry, those are not valid credentials", message: "",  preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Server Call
    func joinCircle() {
        let query = "joinName = '" + self.circleNameField.text! + "' and joinKey = '" + self.circleKeyField.text! + "'"
        print(query)
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(query)
        
        // Query the databaase
        let dataStore = self.backendless.data.of(Circle().ofClass())
        let currentUser = User.getCurrentUser()
        
        dataStore?.find(
            queryBuilder,
            response: {
                (foundCircle) -> () in
                let circles = foundCircle as! [Circle]
                if (circles.isEmpty) {
                    self.alertNoExist()
                    return;
                }
                let circle = circles[0]
                print ("Circle has been successfully found")
                dataStore?.addRelation(
                    "Users",
                    parentObjectId: circle.objectId,
                    childObjects: [currentUser.objectId],
                    response: {
                        (_) -> () in
                        print ("The user has been added to the circle")
                        currentUser.updateProperties(["circleId" : circle.objectId!])
                        self.backendless.userService.update(
                            currentUser,
                            response: {
                                (updatedUser: BackendlessUser?) -> Void in
                                print ("User has been updated") 
                                self.performSegue(withIdentifier: "JoinCircle", sender: self)
                            },
                            error: {
                                (fault : Fault?) -> () in
                                print("Server reported an error: \(String(describing: fault))")
                            }
                        )
                    },
                   error: {
                    (fault : Fault?) -> () in
                    print("Server reported an error: \(String(describing: fault))")
                })
            },
            error: {
                (fault : Fault?) -> () in
                print("Server reported an error: \(String(describing: fault))")
        })
    }

}
