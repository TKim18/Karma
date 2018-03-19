//
//  DirectTransferViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class DirectTransferViewController: UIViewController, KeyboardDelegate, UITextViewDelegate {

    // Local Variables
    var currentTransfer : DirectTransfer!
    var origButtonPosition : CGFloat!
    var numPad = NumPadCalculator(frame: CGRect(x: 0, y: 0, width: 375, height: 216))
    
    // UI Elements
    @IBOutlet weak var costField : UITextField!
    @IBOutlet weak var selectedUser : UILabel!
    @IBOutlet weak var descriptionField : UITextView!
    @IBOutlet weak var requestButton : UIButton!
    @IBOutlet weak var payButton : UIButton!
    @IBOutlet weak var dividerLabel : UILabel!
    var placeholderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        setupKeyboard()
        
        setupDetails()
    }
    
    func setupView() {
        // Set the text of the user label
        selectedUser.text = currentTransfer.selectedUserName
        self.origButtonPosition = requestButton.frame.origin.y
        costField.becomeFirstResponder()
    }
    
    func setupKeyboard() {
        // These are added to push the Request button to appear above the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Adding costField to use the numPad view
        numPad.delegate = self
        costField.inputView = numPad
        
        // Dismissing numPad should evaluate the current expression
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DirectTransferViewController.finishCompute))
        view.addGestureRecognizer(tap)

        // Turn off autocorrect/auto predict for the description field
        descriptionField.autocorrectionType = .no
    }
    
    func setupDetails() {
        // Add ghost text to the details field
        descriptionField!.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "What is this for?"
        placeholderLabel.sizeToFit()
        descriptionField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionField.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !descriptionField.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !descriptionField.text.isEmpty
    }
    
    // Pay/Request Handling
    @IBAction func request(sender : AnyObject) {
        if (validValues() && validRequest()) {
            self.performSegue(withIdentifier: "SubmitDirectTransfer", sender: self)
        }
    }

    @IBAction func pay(sender : AnyObject) {
        if (validValues() && validPay()) {
            self.performSegue(withIdentifier: "SubmitDirectTransfer", sender: self)
        }
    }

    func validValues() -> Bool {
        self.currentTransfer.title = descriptionField.text

        var cost = costField.text!
        if cost.contains("$") {
            cost.remove(at: cost.startIndex)
        }
        
        self.currentTransfer.cost = (cost as NSString).doubleValue
        
        // Validify the values
        if (self.currentTransfer.title!.isEmpty) {
            let alert = UIAlertController(title: "Please enter a description.", message: "e.g., 'For that chicken parm I got you'", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if (costField.text!.isEmpty || self.currentTransfer.cost < 0.01) {
            let alert = UIAlertController(title: "Please enter a valid amount.", message: "Anything greater than $0.00 is fine!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    func validRequest() -> Bool {
        let orderStore = Order.getOrderDataStore()
        let circleStore = Circle.getCircleDataStore()
        let directStore = DirectTransfer.getDTDataStore()
        
        let order = Order()
        
        order.completed = false
        order.title = self.currentTransfer.title
        order.cost = self.currentTransfer.cost
        order.acceptingUserId = self.currentTransfer.currentUserId
        order.acceptingUserName = self.currentTransfer.currentUserName
        order.requestingUserId = self.currentTransfer.selectedUserId
        order.requestingUserName = self.currentTransfer.selectedUserName
        
        orderStore.save(
            order,
            response: {
                (updatedOrder) -> () in
                let newOrder = updatedOrder as! Order
                circleStore.addRelation(
                    "Orders",
                    parentObjectId: UserUtil.getCurrentUserProperty(key: "circleId") as! String,
                    childObjects: [newOrder.objectId!],
                    response: {(num) -> () in ()},
                    error: {(fault : Fault?) -> () in print("Something went wrong adding the order")})
                print("Making a new order object")
        },
            error: { (fault : Fault?) -> () in
                print("Something went wrong trying to make the order object: \(String(describing: fault))")
        })
        
        directStore.save(
            self.currentTransfer,
            response: {
                (updatedRequest) -> () in
                print("Making a new direct transfer object")
        },
            error: {
                (fault : Fault?) -> () in
                print("Something went wrong trying to make the direct transfer: \(String(describing: fault))")
        })
        
        return true
    }
    
    func validPay() -> Bool {
        let userService = Backendless.sharedInstance().userService
        let directStore = DirectTransfer.getDTDataStore()
        
        directStore.save(
            self.currentTransfer,
            response: {
                (updatedRequest) -> () in
                print("Making a new direct transfer object")
        },
            error: {
                (fault : Fault?) -> () in
                print("Something went wrong trying to make the direct transfer: \(String(describing: fault))")
        })
        
        let selectedUser = UserUtil.getUserWithId(userId: self.currentTransfer.selectedUserId)
        let currentUser = UserUtil.getCurrentUser()
        
        let selectedPoints = selectedUser.getProperty("karmaPoints") as! Double
        let currentPoints = currentUser.getProperty("karmaPoints") as! Double
        
        let cost = self.currentTransfer.cost
        let newSelectedPoints = (selectedPoints + cost).rounded(toPlaces: 2)
        let newCurrentPoints = (currentPoints - cost).rounded(toPlaces: 2)
        
        selectedUser.setProperty("karmaPoints", object: newSelectedPoints)
        currentUser.setProperty("karmaPoints", object: newCurrentPoints)
        
        var status = false
        
        Types.tryblock({() -> Void in
            userService!.update(selectedUser)
            userService!.update(currentUser)
            status = true
        },
        catchblock: { (exception) -> Void in
            let error = exception as! Fault
            print(error)
        })
        
        return status
    }
    
    // Helper Functions
    @objc func finishCompute() {
        NumPadCalculator.computeOperation(numPad)()
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyBoardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let unifiedHeight = keyBoardFrame.origin.y - requestButton.frame.size.height
        
        requestButton.frame.origin.y = unifiedHeight
        payButton.frame.origin.y = unifiedHeight
        dividerLabel.frame.origin.y = unifiedHeight
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        requestButton.frame.origin.y = origButtonPosition
        payButton.frame.origin.y = origButtonPosition
        dividerLabel.frame.origin.y = origButtonPosition
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
    
}
