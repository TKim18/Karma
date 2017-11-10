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
        
   }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
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
