//
//  CircleMemberTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MessageUI

class CircleMemberTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {

    var ref: DatabaseReference!
    var members = [DataSnapshot]()
    
    var name: String = ""
    var userName: String = ""
    var id: String = ""
    var circle: String = ""
    
    fileprivate var _addHandle: DatabaseHandle?
    fileprivate var _updateHandle: DatabaseHandle?
    fileprivate var _removeHandle: DatabaseHandle?
    
    let viewColor = UIColor(red: 242, green: 242, blue: 242)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadLocalVariables()
        
        self.ref = Database.database().reference()
        
        self.tableView.backgroundColor = viewColor
        self.tableView.separatorColor = viewColor
        
        loadMembers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func loadLocalVariables() {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CircleMemberTableViewCell", for: indexPath) as? CircleMemberTableViewCell else {
            fatalError("Something's wrong with the Circle Member object!")
        }
        
        let memberSnapshot = members[indexPath.row]
        guard let member = memberSnapshot.value as? [String: Any] else { return cell }
        
        let id = member["id"] as? String ?? ""
        
        cell.nameLabel.text = member["name"] as? String ?? ""
        cell.karmaLabel.text = String(member["karma"] as! Double)
        
        UserUtil.getProperty(key: "photoURL", id: id) { imageString in
            let imageString = imageString as? String ?? "default"
            let imageURL = URL(string: imageString)
            let imagePath = imageURL?.path
            
            UserUtil.getImage(id: id, path: imagePath!, fromCache: false, saveCache: true) { image in
                cell.userImage.image = image
                cell.setNeedsLayout()
            }
        }
        
        cell.layer.borderWidth = 10.0
        cell.layer.borderColor = viewColor.cgColor
        
        if (indexPath.row == 0) {
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    // Slide to accept or delete request
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let member = self.members[indexPath.row]
        
        if let info = member.value as? [String : Any], let number = info["phoneNumber"] as? String {
            let text = UITableViewRowAction(style: .normal, title: "Text") { action, index in
                self.sendTextWithNumber(phoneNumber: number)
            }
            text.backgroundColor = UIColor(rgb: 0x32CD32)
            let call = UITableViewRowAction(style: .normal, title: "Call") { action, index in
                self.callNumber(phoneNumber: number)
            }
            call.backgroundColor = .blue
            
            return [text, call]
        }
        return []
    }
    
    func sendTextWithNumber(phoneNumber: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    func callNumber(phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row != 0)
    }

    private func loadMembers() {
        UserUtil.getCurrentUserName() { userName in
            UserUtil.getCurrentCircle() { circleName in
                let memberRef = self.ref.child("circles/\(circleName)/members")
                
                self._addHandle = memberRef.observe(.childAdded, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    
                    // Swap the current user with the person at the first index
                    if userName != snapshot.key || strongSelf.members.isEmpty {
                        strongSelf.members.append(snapshot)
                        strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.members.count-1, section: 0)], with: .automatic)
                    } else {
                        let temp = strongSelf.members[0]
                        strongSelf.members[0] = snapshot
                        strongSelf.members.append(temp)
                        strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.members.count-1, section: 0)], with: .automatic)
                        strongSelf.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    }
                })
                self._updateHandle = memberRef.observe(.childChanged, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    if let index = strongSelf.members.index(where: {$0.key == snapshot.key}) {
                        strongSelf.members[index] = snapshot
                        strongSelf.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                })
                
                self._removeHandle = memberRef.observe(.childRemoved, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    
                    //TODO: Probably fix this but there's no way to remove anyways
                    if let index = strongSelf.members.index(where: {$0.key == snapshot.key}) {
                        strongSelf.members.remove(at: index)
                        strongSelf.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                })
            }
        }
    }
    
    deinit {
        UserUtil.getCurrentCircle() { circleName in
            let memberRef = self.ref.child("circles/\(circleName)/members")
            if let addHandle = self._addHandle {
                memberRef.removeObserver(withHandle: addHandle)
            }
            if let updateHandle = self._updateHandle {
                memberRef.removeObserver(withHandle: updateHandle)
            }
            if let removeHandle = self._removeHandle {
                memberRef.removeObserver(withHandle: removeHandle)
            }
        }
    }
}
