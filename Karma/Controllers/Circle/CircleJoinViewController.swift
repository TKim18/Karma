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
//        if (self.validValues() && validCircle()) {
//            self.performSegue(withIdentifier: "JoinCircle", sender: self)
//        }
        validCircle()
    }
    
    // Server Call
    override func validCircle() -> Bool {
        let query = "joinName = " + self.circleNameField.text! + " and joinKey = " + self.circleKeyField.text!
        print(query)
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(query)
        
        // Query the databaase
        let dataStore = self.backendless.data.of(Circle().ofClass())
        let currentUser = User.getCurrentUser()
        
        dataStore?.findFirst(
            queryBuilder,
            response: {
                (foundCircle) -> () in
                let circle = foundCircle as! Circle
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
        
        
//        Types.tryblock({ () -> Void in
//            let circle = dataStore!.find(queryBuilder) as! Circle
//            dataStore!.setRelation(
//                "Users",
//                parentObjectId: circle.objectId,
//                childObjects: [currentUser.objectId]
//            )
//            currentUser.updateProperties(["circleId" : circle.objectId!])
//            self.backendless.userService.update(currentUser)
//        }, catchblock: {(exception) -> Void in
//            print(exception ?? "Error")
//            valid = false
//        })
        
        return true
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
    }

}
