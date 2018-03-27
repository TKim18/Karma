//
//  CircleMemberTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class CircleMemberTableViewController: UITableViewController {

    var ref: DatabaseReference!
    
    var members = [DataSnapshot]()
    
    fileprivate var _addHandle: DatabaseHandle?
    fileprivate var _updateHandle: DatabaseHandle?
    fileprivate var _removeHandle: DatabaseHandle?
    
    let viewColor = UIColor(red: 242, green: 242, blue: 242)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = Database.database().reference()
        
        self.tableView.backgroundColor = viewColor
        self.tableView.separatorColor = viewColor
        
        loadMembers()
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
        
        cell.nameLabel.text = member["name"] as? String ?? ""
        cell.karmaLabel.text = String(member["karma"] as! Double)
        cell.userImage.image = #imageLiteral(resourceName: "DefaultAvatar")
        
        cell.layer.borderWidth = 10.0
        cell.layer.borderColor = viewColor.cgColor
        
        if (indexPath.row == 0) {
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    private func loadMembers() {
        UserUtil.getCurrentUserName() { userName in
            UserUtil.getCurrentCircle() { circleName in
                let memberRef = self.ref.child("circles/\(circleName)/members")
                
                self._addHandle = memberRef.observe(.childAdded, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    
                    // Swap the current user with the person at the first index
                    if userName == snapshot.key {
                        let temp = strongSelf.members[0]
                        strongSelf.members[0] = snapshot
                        strongSelf.members.append(temp)
                        strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.members.count-1, section: 0)], with: .automatic)
                        strongSelf.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    } else {
                        strongSelf.members.append(snapshot)
                        strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.members.count-1, section: 0)], with: .automatic)
                    }
                })
                self._updateHandle = memberRef.observe(.childChanged, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    if let index = strongSelf.members.index(where: {$0.key == snapshot.key}) {
                        // TODO: Update the tableview at that cell
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
    
    
    // In preparation for direct transferring
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//
//        guard let selectedCircleCell = sender as? CircleMemberTableViewCell else {
//            fatalError("Unexpected sender: \(String(describing: sender))")
//        }
//
//        guard let indexPath = tableView.indexPath(for : selectedCircleCell) else {
//            fatalError("You definitely got the wrong cell")
//        }
//
//        let selectedUser = members[indexPath.row]
//
//        if let destination = segue.destination as? DirectTransferViewController {
//            let currentTransfer = DirectTransfer(
//                currentUser : UserUtil.getCurrentUser(),
//                selectedUser : selectedUser)
//            destination.currentTransfer = currentTransfer
//        }
//    }
    
    // Swap the current user with the person at the first index
    //                    if userName == snapshot.key {
    //                        strongSelf.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    //                    }
    
    
}
