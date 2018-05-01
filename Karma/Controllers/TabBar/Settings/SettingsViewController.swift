//
//  SettingsViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 5/1/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logoutButton(sender : AnyObject){
        do {
            try Auth.auth().signOut()
            
            // TODO: Memory zombie appears because deinit is never called
            self.navigationController?.popToRootViewController(animated: true)
            self.performSegue(withIdentifier: "logout", sender: self)
        } catch {
            print("Error trying to log out")
        }
    }

}
