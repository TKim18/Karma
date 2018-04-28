//
//  DirectTransferViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import DropDown

class DirectTransferViewController: UIViewController, KeyboardDelegate, UITextViewDelegate {

    // Local Variables
    let dropDown = DropDown()
    var currentTransfer : DirectTransfer!
    var origButtonPosition : CGFloat!
    var numPad = NumPadCalculator(frame: CGRect(x: 0, y: 0, width: 375, height: 216))
    var placeholderLabel : UILabel!
    var userName : String!
    
    var members : [NSDictionary] = []
    var names : [String] = []
    var ids : [String] = []
    var userNames : [String] = []
    var imagePaths : [String] = []

    // UI Elements
    @IBOutlet weak var dropDownView : UIView!
    @IBOutlet weak var costField : UITextField!
    @IBOutlet weak var selectedUser : UIButton!
    @IBOutlet weak var descriptionField : UITextView!
    @IBOutlet weak var requestButton : UIButton!
    @IBOutlet weak var payButton : UIButton!
    @IBOutlet weak var dividerLabel : UILabel!
    @IBAction func cancel(sender : AnyObject) {
        self.view.endEditing(true)
        requestButton.frame.origin.y = view.frame.maxY - requestButton.frame.size.height
        payButton.frame.origin.y = view.frame.maxY - payButton.frame.size.height
        dividerLabel.frame.origin.y = view.frame.maxY - dividerLabel.frame.size.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        setupKeyboard()

        setupDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        costField.becomeFirstResponder()
    }

    // MARK: Setup Methods
    func setupView() {
        loadDropDown()
        
        loadVariables()
        
        loadMembers()
    }
    
    private func loadDropDown() {
        dropDown.anchorView = dropDownView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        // Customize dropdown appearance programmatically
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
        DropDown.appearance().cellHeight = 50
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.selectedUser.setTitle(item, for: .normal)
            self.currentTransfer.selectedName = self.names[index]
            self.currentTransfer.selectedUserName = self.userNames[index]
            self.currentTransfer.selectedUserId = self.ids[index]
        }
    }
    
    private func loadVariables() {
        self.origButtonPosition = requestButton.frame.origin.y
        if let currentUserId = UserUtil.getCurrentId() {
            UserUtil.getCurrentUserName() { currentUserName in
                UserUtil.getCurrentProperty(key: "name") { currentName in
                    self.userName = currentUserName
                    self.currentTransfer = DirectTransfer(
                        currentUserId: currentUserId,
                        currentUserName : currentUserName,
                        currentName: currentName as? String ?? ""
                    )
                }
            }
        }
    }
    
    private func loadMembers() {
        // Convert the members to a list
        Circle.getProperty(key: "members") { members in
            if let membersDic = members as? NSDictionary {
                for (userName, val) in membersDic {
                    if let userName = userName as? String {
                        // Remove the current user from the list
                        if (self.userName != userName) {
                            let memberDic : NSDictionary = [userName : val]
                            self.members.append(memberDic)
                        }
                    }
                }
                // Sort the list by the userName
                self.members.sort { (firstDic, secondDic) -> Bool in
                    let firstUser = Array(firstDic.allKeys).first as! String
                    let secondUser = Array(secondDic.allKeys).first as! String
                    return firstUser == secondUser ? true : firstUser < secondUser
                }
                // Pull out each attribute into a list
                for dict in self.members {
                    for (userName, val) in dict {
                        if let info = val as? NSDictionary, let name = info["name"] as? String, let id = info["id"] as? String, let photo = info["photoURL"] as? String, let userName = userName as? String {
                            self.names.append(name)
                            self.ids.append(id)
                            self.userNames.append(userName)
                            self.imagePaths.append((URL(string: photo)?.path)!)
                        }
                    }
                }
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
    
    @IBAction func displayMembers(sender : AnyObject) {
        dropDown.dataSource = names
        dropDown.cellNib = UINib(nibName: "MemberCell", bundle: nil)
        
        // Configure the cell with the right informaiton
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? MemberCell else { return }
            cell.optionLabel.text = item
            cell.userName.text = self.userNames[index]

            let imagePath = self.imagePaths[index]
            let id = self.ids[index]
            
            UserUtil.getImage(id: id, path: imagePath, fromCache: true, saveCache: false) { image in
                cell.userImage.image = image
                cell.setNeedsLayout()
            }
        }
        dropDown.show()
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
        // Must select a user
        if self.currentTransfer.selectedUserId == "" {
            let alert = UIAlertController(title: "Please select a user first", message: "It's always more fun with a friend", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
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
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !descriptionField.text.isEmpty
    }
    
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


