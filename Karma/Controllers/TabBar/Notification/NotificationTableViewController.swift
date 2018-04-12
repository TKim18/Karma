//
//  RespondRequestTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/26/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseDatabase
import FirebaseStorage

class NotificationTableViewController: UITableViewController {

    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    var notifications : [DataSnapshot]! = []
    
    fileprivate var _addHandle: DatabaseHandle?
    fileprivate var _removeHandle: DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        self.tabBarController?.tabBar.items![1].badgeValue = nil
        
        listenNotifications()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    //Load the data into the table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as? NotificationTableViewCell else {
            fatalError("Something's wrong with the Order object!")
        }

        let notifSnapshot = notifications[indexPath.row]
        guard let notification = notifSnapshot.value as? [String: Any], let info = notification["info"] as? [String: Any], let accUser = notification["acceptUser"] as? [String: Any] else { return cell }

        let title = info["title"] as? String ?? ""
        let cost = info["points"] as! Double
        let name = accUser["name"] as? String ?? ""
        let acceptId = accUser["id"] as? String ?? ""
        
        UserUtil.getProperty(key: "photoURL", id: acceptId) { imageString in
            let imageString = imageString as? String ?? "default"
            let imageURL = URL(string: imageString)
            let imagePath = imageURL?.path
            
            UserUtil.getImage(id: acceptId, path: imagePath!, fromCache: true, saveCache: true) { image in
                cell.userImage.image = image
                cell.setNeedsLayout()
            }
        }
        
        cell.personalMessage.text = title
        cell.notificationLabel.text = name + " requests " + String(cost) + " points"
        
        cell.payButton.addTarget(self, action: #selector(self.completeTransaction), for: UIControlEvents.touchUpInside)
        cell.declineButton.addTarget(self, action: #selector(self.rejectTransaction), for: UIControlEvents.touchUpInside)

        return cell
    }
    
    @objc func completeTransaction(sender: AnyObject) {
        if let cell = sender.superview??.superview as? NotificationTableViewCell {
            let indexPath = self.tableView.indexPath(for: cell)
            performServerTransaction(selectedRequest: notifications[indexPath!.row])
        }
    }
    
    @objc func rejectTransaction(sender: AnyObject) {
        if let cell = sender.superview??.superview as? NotificationTableViewCell {
            let indexPath = self.tableView.indexPath(for: cell)
            Order.rejectRequest(orderSnapshot: notifications[indexPath!.row])
        }
    }
    
    // Segue preparation
    private func performServerTransaction(selectedRequest : DataSnapshot) {
        Order.completeRequest(orderSnapshot: selectedRequest)
        UserUtil.transactPointsWithSnapshot(snapshot: selectedRequest)
    }

    // Server Call
    private func listenNotifications() {
        UserUtil.getCurrentUserName() { userName in
            UserUtil.getCurrentCircle() { circle in
                let orderRef = self.ref.child("acceptedOrders/request/\(circle)/\(userName)")
                let notifTab = self.tabBarController?.tabBar.items![1]
                
                self._addHandle = orderRef.observe(.childAdded, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    strongSelf.notifications.append(snapshot)
                    strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.notifications.count-1, section: 0)], with: .automatic)
                    notifTab?.badgeValue = String(describing: strongSelf.notifications.count)
                })
                self._removeHandle = orderRef.observe(.childRemoved, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    
                    if let index = strongSelf.notifications.index(where: {$0.key == snapshot.key}) {
                        strongSelf.notifications.remove(at: index)
                        strongSelf.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                    if strongSelf.notifications != [] {
                        notifTab?.badgeValue = String(describing: strongSelf.notifications.count)
                    } else {
                        notifTab?.badgeValue = nil
                    }
                })
            }
        }
    }
    
    deinit {
        UserUtil.getCurrentUserName() { userName in
            UserUtil.getCurrentCircle() { circle in
                let acceptRef = self.ref.child("acceptedOrders/request/\(circle)/\(userName)")
                if let addHandle = self._addHandle {
                    acceptRef.removeObserver(withHandle: addHandle)
                }
                if let removeHandle = self._removeHandle {
                    acceptRef.removeObserver(withHandle: removeHandle)
                }
            }
        }
    }
}


