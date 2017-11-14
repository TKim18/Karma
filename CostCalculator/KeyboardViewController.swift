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
    
    private var firstExp = ""
    private var secondExp = ""
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
        firstExp = ""
        secondExp = ""
        resetParams()
    }
    
    func resetParams() {
        shouldClearDisplayBeforeInserting = true
        op = Operation.None
    }
    
    func evalExp () -> Double {
        let firstNum : Double = (firstExp as NSString).doubleValue
        let secondNum : Double = (secondExp as NSString).doubleValue
        
        return eval(x: firstNum, y: secondNum)
    }
    
    
    func eval (x: Double, y: Double) -> Double {
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
        if (op == Operation.None) { return }
        if (op != Operation.None && secondExp == "") {
            display.text = firstExp
            return
        }
        
        // Evaluate the expression
        let result = evalExp()
        
        // The result will become the next firstExp and secondExp will be cleared
        firstExp = "\(result)"
        secondExp = ""
        
        // If the result is an integer don't show the decimal point
        if firstExp.hasSuffix(".0") {
            firstExp = "\(Int(result))"
        }
        
        // Cut down the output to two decimal points
        var components = firstExp.components(separatedBy: ".")
        if components.count >= 2 {
            let beforePoint = components[0]
            var afterPoint = components[1]
            if afterPoint.lengthOfBytes(using: String.Encoding.utf8) > 2 {
                let index: String.Index = afterPoint.index(afterPoint.startIndex, offsetBy: 2)
                afterPoint = String(afterPoint[..<index])
            }
            firstExp = beforePoint + "." + afterPoint
        }
        
        // Update the text and internal parameters
        display.text = firstExp
        resetParams()
    }
    
    @IBAction func didTapNumber(number: UIButton) {
        if (shouldClearDisplayBeforeInserting) {
            display.text = ""
            shouldClearDisplayBeforeInserting = false
        }
        
        if let numberAsString = number.titleLabel?.text {
            let numberAsNSString = numberAsString as NSString
            
            // There is no operation specified
            if (op == Operation.None) {
                firstExp += numberAsString
            }
            // When there is already an operation in the text field
            else {
                secondExp += numberAsString
            }
            
            if let oldDisplay = display?.text {
                display.text = "\(oldDisplay)\(numberAsNSString.intValue)"
            }
            else {
                display.text = "\(numberAsNSString.intValue)"
            }
        }
    }
    
    @IBAction func didTapOperation(operation: UIButton) {
        if (op != Operation.None && firstExp != "" && secondExp != "") { computeOperation() }
        
        if let opString = operation.titleLabel?.text {
            if var oldDisplay = display?.text {
                if (oldDisplay.isEmpty) { return }
                if (op != Operation.None && secondExp == "") {
                    oldDisplay.remove(at: oldDisplay.index(before: oldDisplay.endIndex))
                }
                
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
                shouldClearDisplayBeforeInserting = false
            }
        }
    }
    
    private func hasDot(exp: String) -> Bool {
        for ch in exp.unicodeScalars {
            if ch == "." {
                return true
            }
        }
        return false
    }
    
    @IBAction func didTapDot() {
        if (shouldClearDisplayBeforeInserting) {
            display.text = "0."
            shouldClearDisplayBeforeInserting = false
            firstExp += "."
            return
        }
        
        if ((secondExp == "" && hasDot(exp: firstExp) && op == Operation.None)
            || (secondExp != "" && hasDot(exp: secondExp))) {
            return
        }
        
        if (secondExp == "" && op == Operation.None) {
            firstExp += "."
        }
        else {
            secondExp += "."
        }
        
        if let input = display?.text {
            if input.isEmpty { return }
            display.text = "\(input)."
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
