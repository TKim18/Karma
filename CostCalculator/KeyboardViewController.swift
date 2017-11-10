//
//  KeyboardViewController.swift
//  CostCalculator
//
//  Created by Timothy Taeho Kim on 11/9/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInterface()
   }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    func loadInterface() {
        let calculatorNib = UINib(nibName: "CostCalculator", bundle: nil)
    
        let calculatorView = calculatorNib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        // Add the interface to the main view
        view.addSubview(calculatorView)
        
        // Copy the background color
        view.backgroundColor = calculatorView.backgroundColor
    }
    
}
