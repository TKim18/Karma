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
    @IBOutlet weak var cost : UITextField!
    @IBOutlet weak var selectedUser : UILabel!
    var numPad = NumPadCalculator(frame: CGRect(x: 0, y: 0, width: 375, height: 213))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cost.becomeFirstResponder()
        
        numPad.delegate = self
        
        cost.inputView = numPad
        
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
        cost.insertText(character)
    }
    
    func setText(text: String) {
        cost.text = text
    }
    
    func deleteText() {
        cost.deleteBackward()
    }
    
}
