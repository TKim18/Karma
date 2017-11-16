//
//  CustomRequestViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/27/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CustomRequestViewController: UIViewController, KeyboardDelegate {

    var currentOrder : Order!
    var reqButtonPosition : CGFloat!
    var numPad = NumPadCalculator(frame: CGRect(x: 0, y: 0, width: 375, height: 216))
    
    //UI Elements
    @IBOutlet var categoryImage: UIImageView!
    @IBOutlet var titleField : UITextField!
    @IBOutlet var endTimeField : UITextField!
    @IBOutlet var startLocationField : UITextField!
    @IBOutlet var endLocationField : UITextField!
    @IBOutlet var costField : UITextField!
    @IBOutlet var requestDetailsField : UITextView!
    @IBOutlet var errorMessage : UILabel!
    @IBOutlet var requestButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the category frame at the top
        categoryImage.image = currentOrder.fromDescription().image
        
        // Enable NumPad Calculator for cost and disable autocorrectionType
        setupKeyboard()
        
        self.reqButtonPosition = requestButton.frame.origin.y
    }
    
    func setupKeyboard() {
        // These are added to push the Request button to appear above the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Adding costField to use the numPad view
        costField.becomeFirstResponder()
        numPad.delegate = self
        costField.inputView = numPad
        
        // Dismissing numPad should evaluate the current expression
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CustomRequestViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Turn off autocorrect/auto predict for the other text fields
        titleField.autocorrectionType = .no
        endTimeField.autocorrectionType = .no
        startLocationField.autocorrectionType = .no
        endLocationField.autocorrectionType = .no
        requestDetailsField.autocorrectionType = .no
    }
    
    // Segue handling
    @IBAction func request(sender : AnyObject) {
        if (validRequest()) {
            self.performSegue(withIdentifier: "SubmitRequest", sender: self)
        }
    }

    // Server call
    func validRequest() -> Bool {
        let backendless = Backendless.sharedInstance()!
        let orderDataStore = backendless.data.of(Order().ofClass())
        let circleDataStore = backendless.data.of(Circle().ofClass())
        
        // Populate the attributes
        self.currentOrder.title = titleField.text
        self.currentOrder.message = requestDetailsField.text
        self.currentOrder.requestedTime = endTimeField.text
        self.currentOrder.origin = startLocationField.text
        self.currentOrder.destination = endLocationField.text

        // TODO: Add safety measures to this - cant be below 0.01 or not a number
        self.currentOrder.cost = (costField.text! as NSString).doubleValue
        
        var valid = true
        Types.tryblock({ () -> Void in
            let placedOrder = orderDataStore!.save(self.currentOrder) as! Order
            circleDataStore!.addRelation(
                "Orders",
                parentObjectId: User.getCurrentUserProperty(key: "circleId") as! String,
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

    // Helper Functions:
    @objc func dismissKeyboard() {
        NumPadCalculator.computeOperation(numPad)()
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyBoardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyHeight = keyBoardFrame.origin.y
        let reqHeight = requestButton.frame.size.height
        // keyboard height = 216
        // keyboard height = 213
        requestButton.frame.origin.y = keyHeight - reqHeight
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // TODO implement math logic for this
        requestButton.frame.origin.y = reqButtonPosition
        
    }
    
    // KeyboardDelegate Protocol Implementation:
    func addText(character: String) {
        costField.insertText(character)
    }
    
    func setText(text: String) {
        costField.text = "$" + text
    }
    
    func deleteText() {
        costField.deleteBackward()
    }
    
    func sendRequest(direction: String) {
        switch direction {
        case "Pay":
            // Fill in logic of paying money from one side to another
            return
        case "Request":
            // Fill in logic of requesting money from the selected user
            return
        default:
            return
        }
    }
    
}
