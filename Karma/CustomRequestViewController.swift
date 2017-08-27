//
//  CustomRequestViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/27/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CustomRequestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Bit of data
    var currentOrder : Order?
    
    //UI Elements
    @IBOutlet var titleField : UITextField!
    @IBOutlet var endTimeField : UITextField!
    @IBOutlet var startLocationField : UITextField!
    @IBOutlet var endLocationField : UITextField!
    @IBOutlet var requestDetailsField : UITextField!
    
    @IBAction func requestButton(sender : AnyObject) {
        self.performSegue(withIdentifier: "SubmitRequest", sender: self)
    }


}
