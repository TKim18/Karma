//
//  DirectTransferViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
//import CostCalculator

class DirectTransferViewController: UIViewController, KeyboardDelegate {

    //UI Elements
    @IBOutlet weak var costField : UITextField!
    @IBOutlet weak var selectedUser : UILabel!
    var numPad = NumPadCalculator(frame: CGRect(x: 0, y: 0, width: 375, height: 213))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        costField.becomeFirstResponder()
    }
    
    func setupKeyboard() {
        numPad.delegate = self
        
        costField.inputView = numPad
        
        selectedUser.text = "Hello!"
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DirectTransferViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        NumPadCalculator.computeOperation(numPad)()
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Bit of data
    //var currentTransfer : DirectTransfer!

    func addText(character: String) {
        costField.insertText(character)
    }
    
    func setText(text: String) {
        costField.text = text
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
