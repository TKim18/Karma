//
//  DirectTransferViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class DirectTransferViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedUser.text = "Hello!"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Bit of data
    var currentTransfer : DirectTransfer!

    //UI Elements
    @IBOutlet var cost : UITextField!
    @IBOutlet var selectedUser : UILabel!
    
    
}
