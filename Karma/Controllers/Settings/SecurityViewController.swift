//
//  SecurityViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 4/8/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseAuth

class SecurityViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutButton(sender : AnyObject){
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logout", sender: self)
        } catch {
            print("Error trying to log out")
        }
    }
}
