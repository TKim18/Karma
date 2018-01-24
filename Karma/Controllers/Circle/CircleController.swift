//
//  CircleController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CircleController: UIViewController {

    // UI Elements
    @IBOutlet var circleNameField : UITextField!
    @IBOutlet var circleKeyField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setBackground()
    }
    
    func validValues() -> Bool {
        if (circleNameField.text.isEmpty) {
            let alert = UIAlertController(title: "Please enter a name.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addaction(uIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }

//    func setBackground() {
//        let backgroundImage = UIImage(named: "ClassicBackground")
//
//        var imageView : UIImageView!
//        imageView = UIImageView(frame: view.bounds)
//        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.image = backgroundImage
//        imageView.center = view.center
//        view.addSubview(imageView)
//        self.view.sendSubviewToBack(imageView)
//    }

}
