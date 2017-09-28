//
//  CustomRequestViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/27/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CustomRequestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryImage.image = currentOrder.fromDescription().image

        //categoryImage.image = currentOrder.fromDescription(description: currentOrder.category!).image
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Bit of data
    var currentOrder : Order!
    
    //UI Elements
    @IBOutlet var titleField : UITextField!
    @IBOutlet var endTimeField : UITextField!
    @IBOutlet var startLocationField : UITextField!
    @IBOutlet var endLocationField : UITextField!
    @IBOutlet var requestDetailsField : UITextView!
    @IBOutlet var errorMessage : UILabel!
    @IBOutlet var categoryImage: UIImageView!
    
    @IBAction func requestButton(sender : AnyObject) {
        if (validRequest()) {
            self.performSegue(withIdentifier: "SubmitRequest", sender: self)
        }
    }

    //Server call
    func validRequest() -> Bool {
        let backendless = Backendless.sharedInstance()!
        let orderDataStore = backendless.data.of(Order().ofClass())
        let circleDataStore = backendless.data.of(Circle().ofClass())
        let currentUser = backendless.userService.currentUser
        
        //Populate the attributes
        self.currentOrder.title = titleField.text
        self.currentOrder.message = requestDetailsField.text
        self.currentOrder.requestedTime = endTimeField.text
        self.currentOrder.origin = startLocationField.text
        self.currentOrder.destination = endLocationField.text
        
        var valid = true
        Types.tryblock({ () -> Void in
            let placedOrder = orderDataStore!.save(self.currentOrder) as! Order
            circleDataStore!.addRelation(
                "Orders",
                parentObjectId: currentUser!.getProperty("circleId") as! String,
                childObjects: [placedOrder.objectId!]
            )
        },
        catchblock: { (exception) -> Void in
            let error = exception as! Fault
            self.errorMessage.text = error.message
            valid = false
        })
        
        return valid

    }

}
