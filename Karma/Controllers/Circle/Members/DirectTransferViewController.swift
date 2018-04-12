//
//  DirectTransferViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import SearchTextField

class DirectTransferViewController: UIViewController, KeyboardDelegate, UITextViewDelegate {

    // Local Variables
    var currentTransfer : DirectTransfer!
    var members : [SearchTextFieldItem]!
    var origButtonPosition : CGFloat!
    var numPad = NumPadCalculator(frame: CGRect(x: 0, y: 0, width: 375, height: 216))
    var placeholderLabel : UILabel!
    var name: String = ""
    var userName: String = ""
    var id: String = ""
    var circle: String = ""

    // UI Elements
    @IBOutlet weak var costField : UITextField!
    @IBOutlet weak var selectUserField : SearchTextField!
    @IBOutlet weak var descriptionField : UITextView!
    @IBOutlet weak var requestButton : UIButton!
    @IBOutlet weak var payButton : UIButton!
    @IBOutlet weak var dividerLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

        setupKeyboard()

        setupDetails()
    }

    // MARK: Setup Methods
    func setupView() {
        selectUserField.becomeFirstResponder()
        selectUserField.theme = SearchTextFieldTheme.darkTheme()
        selectUserField.theme.cellHeight = 70
        
        loadVariables()
        
        loadMembers()
    }
    
    private func loadVariables() {
        self.members = []
        self.origButtonPosition = requestButton.frame.origin.y
        self.currentTransfer = DirectTransfer(currentUserId: self.id, currentUserName : self.userName, currentName: self.name)
        if let currentUserId = UserUtil.getCurrentId() {
            UserUtil.getCurrentUserName() { currentUserName in
                UserUtil.getCurrentProperty(key: "name") { currentName in
                    UserUtil.getCurrentCircle() { circleName in
                        self.name = currentName as? String ?? ""
                        self.userName = currentUserName
                        self.id = currentUserId
                        self.circle = circleName
                    }
                }
            }
        }
    }
    
    private func loadMembers() {
        Circle.getProperty(key: "members") { members in
            if let membersDic = members as? NSDictionary {
                for (userName, val) in membersDic {
                    if let member = val as? NSDictionary, let name = member["name"] as? String, let id = member["id"] as? String, let userName = userName as? String {
                        self.members.append(SearchMemberFieldItem(title: name, subtitle: userName, id: id, image: #imageLiteral(resourceName: "DefaultAvatar")))
                    }
                }
                self.selectUserField.filterItems(self.members)
            }
        }
    }
    
    func setupKeyboard() {
        // These are added to push the Request button to appear above the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Adding costField to use the numPad view
        numPad.delegate = self
        costField.inputView = numPad
        
        // Dismissing numPad should evaluate the current expression
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DirectTransferViewController.finishCompute))
        view.addGestureRecognizer(tap)
        
        // Turn off autocorrect/auto predict for the description field
        descriptionField.autocorrectionType = .no
    }
    
    func setupDetails() {
        // Add ghost text to the details field
        descriptionField!.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "What is this for?"
        placeholderLabel.sizeToFit()
        descriptionField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionField.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !descriptionField.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !descriptionField.text.isEmpty
    }
    
    // Pay/Request Handling
    @IBAction func request(sender : AnyObject) {
        if validValues() {
            self.currentTransfer.performRequest() {
                self.performSegue(withIdentifier: "SubmitDirectTransfer", sender: self)
            }
        }
    }

    @IBAction func pay(sender : AnyObject) {
        if validValues() {
            self.currentTransfer.performPay() {
                self.performSegue(withIdentifier: "SubmitDirectTransfer", sender: self)
            }
        }
    }

    func validValues() -> Bool {
        self.currentTransfer.title = descriptionField.text

        var cost = costField.text!
        if cost.contains("$") {
            cost.remove(at: cost.startIndex)
        }

        self.currentTransfer.cost = (cost as NSString).doubleValue

        // Validify the values
        if (self.currentTransfer.title!.isEmpty) {
            let alert = UIAlertController(title: "Please enter a description.", message: "e.g., 'For that chicken parm I got you'", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if (costField.text!.isEmpty || self.currentTransfer.cost < 0.01) {
            let alert = UIAlertController(title: "Please enter a valid amount.", message: "Anything greater than $0.00 is fine!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }

        return true
    }
    
    // MARK: Helper Functions
    @objc func finishCompute() {
        NumPadCalculator.computeOperation(numPad)()
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let keyBoardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let unifiedHeight = keyBoardFrame.origin.y - requestButton.frame.size.height

        requestButton.frame.origin.y = unifiedHeight
        payButton.frame.origin.y = unifiedHeight
        dividerLabel.frame.origin.y = unifiedHeight
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        requestButton.frame.origin.y = origButtonPosition
        payButton.frame.origin.y = origButtonPosition
        dividerLabel.frame.origin.y = origButtonPosition
    }

    // MARK: KeyboardDelegate Protocol Implementation
    func addText(character: String) {
        costField.insertText(character)
    }

    func setText(text: String) {
        costField.text = "$" + text
    }

    func deleteText() {
        costField.deleteBackward()
    }

}


