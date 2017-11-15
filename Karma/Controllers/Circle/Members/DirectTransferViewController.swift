//
//  DirectTransferViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class DirectTransferViewController: UIViewController, KeyboardDelegate {

    // UI Elements
    @IBOutlet weak var costField : UITextField!
    @IBOutlet weak var selectedUser : UILabel!
    
    // Initialize the NumPad keyboard
    var numPad = NumPadCalculator(frame: CGRect(x: 0, y: 0, width: 375, height: 213))
    
    // Pull the current user data
    var currentTransfer : DirectTransfer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedUser.text = currentTransfer.selectedUserName
        
        setupKeyboard()
    }
    
    func setupKeyboard() {
        costField.becomeFirstResponder()
        
        numPad.delegate = self
        costField.inputView = numPad
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DirectTransferViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }

    // Call this when keyboard is dismissed
    @objc func dismissKeyboard() {
        // Evaluate the current state
        NumPadCalculator.computeOperation(numPad)()
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
