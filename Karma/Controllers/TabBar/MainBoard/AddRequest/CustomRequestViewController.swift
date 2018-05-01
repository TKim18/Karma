//
//  CustomRequestViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/27/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class CustomRequestViewController: UIViewController, KeyboardDelegate, UITextViewDelegate {
    
    // Local Variables
    var order : Order!
    var reqButtonPosition : CGFloat!
    var numPad : NumPadCalculator! = NumPadCalculator(frame: CGRect(x: 0, y: 0, width: 375, height: 216))
    
    // UI Elements
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleField : UITextField!
    @IBOutlet weak var endTimeField : UITextField!
    @IBOutlet weak var locationField : UITextField!
    @IBOutlet weak var costField : UITextField!
    @IBOutlet weak var requestDetailsField : UITextView!
    @IBOutlet weak var errorMessage : UILabel!
    @IBOutlet weak var requestButton : UIButton!
    @IBOutlet weak var menuButton : UIBarButtonItem!
    @IBOutlet weak var requestBottomConstraint: NSLayoutConstraint!

    var placeholderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set miscellaneous view configurations
        setupView()
        
        // Configure the various keyboard types
        setupKeyboard()
        
        // Set there to be gray text on the request details field
        setupDetails()
    }
    
    func setupView() {
        self.reqButtonPosition = requestBottomConstraint.constant
        
        
        if let category = order.category {
            // Set the category images
            self.categoryImage.image = category.brightImage
            
            // WeShop and Custom both do not have menus
            if category == .WeShop || category == .Custom { self.menuButton.title = "" }
            
            // Custom should have title field as its first text with nothing inside
            if (category == .Custom) {
                self.titleField.becomeFirstResponder()
                self.titleField.text = ""
            } else {
                self.locationField.becomeFirstResponder()
                self.titleField.text = category.description
            }
        }
    }
    
    func setupKeyboard() {
        // These are added to push the Request button to appear above the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Adding costField to use the numPad view
        numPad.delegate = self
        costField.inputView = numPad
        
        // Dismissing numPad should evaluate the current expression
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CustomRequestViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Turn off autocorrect/auto predict for the other text fields
        titleField.autocorrectionType = .no
        endTimeField.autocorrectionType = .no
        locationField.autocorrectionType = .no
        requestDetailsField.autocorrectionType = .no
    }
    
    func setupDetails() {
        // Insert ghost text when no text
        requestDetailsField.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "What would you like to request?"
        placeholderLabel.font = UIFont(name: (requestDetailsField.font?.fontName)!, size: (requestDetailsField.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        requestDetailsField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (requestDetailsField.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !requestDetailsField.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !requestDetailsField.text.isEmpty
    }
    
    // Date and Time Picker
    @IBAction func triggerDatePicker(_ sender : UIButton) {
        view.endEditing(true)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        
        let datePicker = ActionSheetDatePicker(title: "Pick Due Date and Time:", datePickerMode: UIDatePickerMode.dateAndTime, selectedDate: Date(timeInterval: 3600, since: Date()), doneBlock: {
            picker, value, index in
            if let value = value as? Date{
                self.endTimeField.text = formatter.string(from: value)
            }
            
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!)
        let secondsInThreeWeek: TimeInterval = 7 * 24 * 60 * 60 * 3
        let secondsInAnHour : TimeInterval = 60 * 60
        datePicker?.minimumDate = Date(timeInterval: secondsInAnHour, since: Date())
        datePicker?.maximumDate = Date(timeInterval: secondsInThreeWeek, since: Date())
        datePicker?.minuteInterval = 10
        datePicker?.show()
    }
    
    // Segue handling
    @IBAction func request(sender : AnyObject) {
        populateOrder()
        
        if validifyOrder() {
            setDefaults()
            
            order.upload() {
                self.performSegue(withIdentifier: "SubmitRequest", sender: self)
            }
        }
    }
    
    func populateOrder() {
        order.title = titleField.text
        order.details = requestDetailsField.text
        order.time = endTimeField.text
        order.destination = locationField.text
        
        // Cost field
        var cost = costField.text!
        if cost.contains("$") {
            cost.remove(at: cost.startIndex)
        }
    
        order.cost = (cost as NSString).doubleValue
    }

    func validifyOrder() -> Bool {
        if (order.title!.isEmpty) {
            self.errorMessage.text = "Please give this request a title!"
            return false
        }
        else if (costField.text!.isEmpty) {
            self.errorMessage.text = "Please specify the amount of Karma!"
            return false
        }
        return true
    }
    
    func setDefaults() {
        if (order.destination!.isEmpty) {
            order.destination = "Home"
        }
        
        if (order.time!.isEmpty) {
            order.time = "ASAP"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let iden = segue.identifier
        if iden == "OpenMenu" {
            let currentCategory = order.category
            if let destination = segue.destination as? MenuViewController {
                destination.category = currentCategory
            }
        }
    }

    // Helper Functions:
    @objc func dismissKeyboard() {
        NumPadCalculator.computeOperation(numPad)()
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        requestBottomConstraint.constant = reqButtonPosition
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        requestBottomConstraint.constant = 0
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
