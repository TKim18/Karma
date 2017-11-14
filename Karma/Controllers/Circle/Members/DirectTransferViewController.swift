//
//  DirectTransferViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class DirectTransferViewController: UIViewController, KeyboardDelegate {

    //UI Elements
    @IBOutlet weak var cost : UITextField!
    @IBOutlet weak var selectedUser : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cost.becomeFirstResponder()
        
       //cost.text =
        let numPad = NumPadCalculator()
        numPad.delegate = self
        
        cost.inputView = numPad
        
        selectedUser.text = "Hello!"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Bit of data
    var currentTransfer : DirectTransfer!

    
    
}
