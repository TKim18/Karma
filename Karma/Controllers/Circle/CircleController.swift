//
//  CircleController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CircleController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UI Elements
    @IBOutlet var circleNameField : UITextField!
    
    @IBAction func createCircle(sender : AnyObject) {
        if (validCircle()) {
            self.performSegue(withIdentifier: "CircleToMain", sender: self)
        }
    }
    
    //Server Call
    func validCircle() -> Bool {
        let backendless = Backendless.sharedInstance()!
        let dataStore = backendless.data.of(Circle().ofClass())
        
        let circle = Circle(name: circleNameField.text!)
        let currentUser : BackendlessUser = backendless.userService.currentUser
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
