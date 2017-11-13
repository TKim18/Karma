//
//  KeyboardViewController.swift
//  CostCalculator
//
//  Created by Timothy Taeho Kim on 11/9/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

enum Operation {
    case Addition
    case Multiplication
    case Subtraction
    case Division
    case None
    
    static let allOperations = "+−×÷"

}

class KeyboardViewController: UIInputViewController {
    
    private var shouldClearDisplayBeforeInserting = true
    private var internalMemory = 0.0
    private var nextOperation = Operation.None
    private var readyToCompute = false
    private var shouldCompute = false
    
    let letters = CharacterSet.letters
    let digits = CharacterSet.decimalDigits

    
    private var containsOp = false
    private var op = Operation.None
    
    @IBOutlet var display: UILabel!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInterface()
        clearDisplay()
   }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    @IBAction func clearDisplay() {
        display.text = "0"
        resetParams()
    }
    
    func resetParams() {
        shouldClearDisplayBeforeInserting = true
        containsOp = false
        op = Operation.None
    }
    
    func evalExp (exp : String) -> Double {
        var firstNumString : String = ""
        var currNumString : String = ""
        
        for c in exp.unicodeScalars {
            if (digits.contains(c) || c == ".") {
                currNumString += String(c)
            }
            else {
                firstNumString = currNumString
                currNumString = ""
            }
        }
        
        let firstNum : Double = (firstNumString as NSString).doubleValue
        let secondNum : Double = (currNumString as NSString).doubleValue
        
        return eval(x: firstNum, y: secondNum)
    }
    
    
    func eval (x : Double, y : Double) -> Double {
        var result = 0.0
        switch op {
            case .Addition:
                result = x + y
            case .Subtraction:
                result = x - y
            case .Multiplication:
                result = x * y
            case .Division:
                if (y == 0) {
                    return 0.0
                }
                result = x / y
            default:
                result = 0.0
        }
        return result
    }
    
    @IBAction func computeOperation() {
        if (op == Operation.None || !containsOp) { return }
        
        if let input = display?.text {
            // Evaluate the expression
            let result = evalExp(exp: input)
            
            // Stringify it
            var output = "\(result)"
            
            // If the result is an integer don't show the decimal point
            if output.hasSuffix(".0") {
                output = "\(Int(result))"
            }
            
            // Cut down the output to two decimal points
            var components = output.components(separatedBy: ".")
            if components.count >= 2 {
                let beforePoint = components[0]
                var afterPoint = components[1]
                if afterPoint.lengthOfBytes(using: String.Encoding.utf8) > 2 {
                    let index: String.Index = afterPoint.index(afterPoint.startIndex, offsetBy: 2)
                    afterPoint = String(afterPoint[..<index])
                }
                output = beforePoint + "." + afterPoint
            }
            
            // Update the text and internal parameters
            display.text = output
            resetParams()
        }
    }
    
    @IBAction func didTapNumber(number: UIButton) {
        if (shouldClearDisplayBeforeInserting) {
            display.text = ""
            shouldClearDisplayBeforeInserting = false
        }
        
        if let numberAsString = number.titleLabel?.text {
            let numberAsNSString = numberAsString as NSString
            if let oldDisplay = display?.text {
                display.text = "\(oldDisplay)\(numberAsNSString.intValue)"
            }
            else {
                display.text = "\(numberAsNSString.intValue)"
            }
        }
    }
    
    @IBAction func didTapOperation(operation: UIButton) {
        if (containsOp) { computeOperation() }
        if let opString = operation.titleLabel?.text {
            if let oldDisplay = display?.text {
                //Make sure there is only one
                if (oldDisplay.isEmpty) { return }
                
                switch opString {
                    case "+":
                        display.text = oldDisplay + "+"
                        op = Operation.Addition
                    case "−":
                        display.text = oldDisplay + "−"
                        op = Operation.Subtraction
                    case "×":
                        display.text = oldDisplay + "×"
                        op = Operation.Multiplication
                    case "÷":
                        display.text = oldDisplay + "÷"
                        op = Operation.Division
                    default:
                        display.text = oldDisplay
                        op = Operation.None
                }
                containsOp = true
                shouldClearDisplayBeforeInserting = false
            }
        }
    }
    
    @IBAction func didTapDot() {
        if let input = display?.text {
            if input.isEmpty { return }
            var hasDot = false
            //Split the two numbers on either side of hte operator
            for ch in input.unicodeScalars {
                if ch == "." {
                    hasDot = true
                    break
                }
            }
            if hasDot == false {
                display.text = "\(input)."
            }
        }
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
