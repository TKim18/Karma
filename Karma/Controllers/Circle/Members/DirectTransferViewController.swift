//
//  DirectTransferViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class DirectTransferViewController: UIViewController, KeyboardDelegate {

    // Local Variables
    var numPad = NumPadCalculator(frame: CGRect(x: 0, y: 0, width: 375, height: 213))
    var currentTransfer : DirectTransfer!
    
    // UI Elements
    @IBOutlet weak var costField : UITextField!
    @IBOutlet weak var selectedUser : UILabel!
    
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
