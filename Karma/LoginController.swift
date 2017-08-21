//
//  LoginController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    //Override functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UI Elements
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!

    @IBAction func loginButton(sender : AnyObject) {
        shouldPerformSegue(withIdentifier: "LoginToMain", sender: nil)
    }
    
    @IBAction func showRegister(sender : AnyObject) {
        shouldPerformSegue(withIdentifier: "LoginToRegister", sender: nil)
    }
    

}
