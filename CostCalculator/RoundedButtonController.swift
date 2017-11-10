//
//  RoundedButtonController.swift
//  CostCalculator
//
//  Created by Timothy Taeho Kim on 11/9/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButtonController: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //backgroundColor = .clear
        layer.cornerRadius = 5
        layer.borderWidth = 0
        layer.borderColor = UIColor.black.cgColor
        setTitleColor(.black, for: .normal)
    }
    
}
