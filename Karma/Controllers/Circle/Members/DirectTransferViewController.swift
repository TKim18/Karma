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
    @IBOutlet weak var errorMessage : UILabel!
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
        if (validRequest()) {
            self.performSegue(withIdentifier: "SubmitRequest", sender: self)
        }
    }

    @IBAction func pay(sender : AnyObject) {
        if (validPay()) {
            self.performSegue(withIdentifier: "SubmitRequest", sender: self)
        }
    }

    func validValues() -> Bool {
        let DTDataStore = DirectTransfer.getDTDataStore()
        self.currentTransfer.title = descriptionField.text

        var cost = costField.text!
        if cost.characters.contains("$") {
            cost.remove(at: cost.startIndex)
        }
        
        self.currentTransfer.cost = (cost as NSString).doubleValue
        
        // Validify the values and set defaults
        if (self.currentTransfer.title!.isEmpty) {
            let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if (costField.text!.isEmpty) {
            self.errorMessage.text = "Please specify the amount of Karma!"
            return false
        }
        
        var valid = true
        Types.tryblock({ () -> Void in
            orderDataStore!.save(self.currentOrder) as! Order
        },
        catchblock: { (exception) -> Void in
            let error = exception as! Fault
            self.errorMessage.text = error.message
            valid = false
        })
    }
    
    func validRequest() -> Bool {
        
        return true
    }
    
    func validPay() -> Bool {
        
        return true
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
