//
//  NumPadCalculator.swift
//  CostCalculator
//
//  Created by Timothy Taeho Kim on 11/14/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

public protocol KeyboardDelegate: class {
    func addText(character: String)
    func setText(text: String)
    func deleteText()
}

enum Operation {
    case Addition
    case Multiplication
    case Subtraction
    case Division
    case None
}

public class NumPadCalculator: UIView {
    var delegate: KeyboardDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    func initializeSubviews() {
        let calculatorNib = UINib(nibName: "CostCalculator", bundle: nil)
        let calculatorView = calculatorNib.instantiate(withOwner: self, options: nil)[0] as! UIView

        self.addSubview(calculatorView)
        self.frame = self.bounds
        self.backgroundColor = calculatorView.backgroundColor
    }
    
    // Logic Variables
    private var firstExp = ""
    private var secondExp = ""
    private var op = Operation.None
    private var shouldClearDisplayBeforeInserting = true
    private var internalText = ""

    //@IBOutlet var display: UILabel!
    
    // Keyboard Actions/Key Taps
    
    // C
    @IBAction func clearDisplay() {
        setText(text: "0")
        firstExp = ""
        secondExp = ""
        resetParams()
    }

    // 0-9
    @IBAction func didTapNumber(number: UIButton) {
        if (shouldClearDisplayBeforeInserting) {
            setText(text: "")
            shouldClearDisplayBeforeInserting = false
        }

        if let numberAsString = number.titleLabel?.text {
            // There is no operation specified
            if (op == Operation.None) {
                firstExp += numberAsString
            }
            // When there is already an operation in the text field
            else {
                secondExp += numberAsString
            }
            addText(char: numberAsString, prev: internalText)
        }
    }

    // +-/*
    @IBAction func didTapOperation(operation: UIButton) {
        //Ex: 4 + 2 - => 6 -
        if (op != Operation.None && firstExp != "" && secondExp != "") { computeOperation() }

        if let opString = operation.titleLabel?.text {
            if (internalText.isEmpty) { return }

            //Ex: 4 + - => 4 -
            if (op != Operation.None && secondExp == "") {
                deleteText()
            }

            switch opString {
                case "+":
                    addText(char: "+", prev: internalText)
                    op = Operation.Addition
                case "−":
                    addText(char: "−", prev: internalText)
                    op = Operation.Subtraction
                case "×":
                    addText(char: "×", prev: internalText)
                    op = Operation.Multiplication
                case "÷":
                    addText(char: "÷", prev: internalText)
                    op = Operation.Division
                default:
                    addText(char: "", prev: internalText)
                    op = Operation.None
                }
            shouldClearDisplayBeforeInserting = false
        }
    }

    // .
    @IBAction func didTapDot() {
        if (shouldClearDisplayBeforeInserting) {
            setText(text: "0.")
            shouldClearDisplayBeforeInserting = false
            firstExp += "."
            return
        }

        if ((secondExp == "" && hasDot(exp: firstExp) && op == Operation.None)
            || (secondExp != "" && hasDot(exp: secondExp))) {
            return
        }

        if (secondExp == "" && op == Operation.None) { firstExp += "." }
        else { secondExp += "." }

        if (internalText.isEmpty) { return }
        addText(char: ".", prev: internalText)
    }

    //----------- Helper Functions -------------//
    
    private func resetParams() {
        shouldClearDisplayBeforeInserting = true
        op = Operation.None
    }
    
    func computeOperation() {
        // Can't evaluate when there's no operator
        // Ex: eval("4")
        if (op == Operation.None) { return }
        
        // If there is an operator but no secondExp
        // Ex: eval("4+") => "4"
        if (op != Operation.None && secondExp == "") {
            setText(text: firstExp)
            op = Operation.None
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
        setText(text: firstExp)
        resetParams()
    }
    
    private func evalExp () -> Double {
        let firstNum : Double = (firstExp as NSString).doubleValue
        let secondNum : Double = (secondExp as NSString).doubleValue
        
        return eval(x: firstNum, y: secondNum)
    }
    
    private func eval (x: Double, y: Double) -> Double {
        var result = 0.0
        switch op {
        case .Addition:
            result = x + y
        case .Subtraction:
            result = (x - y < 0) ? 0 : (x - y)
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
        if (result > 0 && result < 0.001) { result = 0.0 }
        return result
    }
    
    private func addText(char: String, prev: String) {
        internalText = prev + char
        self.delegate?.addText(character: char)
    }
    
    private func setText(text: String) {
        internalText = text
        self.delegate?.setText(text: text)
    }
    
    private func deleteText() {
        internalText.remove(at: internalText.index(before: internalText.endIndex))
        self.delegate?.deleteText()
    }
    
    private func hasDot(exp: String) -> Bool {
        for ch in exp.unicodeScalars {
            if ch == "." {
                return true
            }
        }
        return false
    }
    
}
