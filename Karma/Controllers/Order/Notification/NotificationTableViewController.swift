//
//  RespondRequestTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/26/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NotificationTableViewController: UITableViewController {

    var ref: DatabaseReference!
    
    var notifications : [DataSnapshot]! = []
    
    fileprivate var _acceptAddHandle: DatabaseHandle?
    fileprivate var _acceptRemoveHandle: DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = Database.database().reference()
        
        listenNotifications()

        // self.tabBarController?.tabBar.items![1].badgeValue = String(notifications.count)
    }
    
    // One section for pending, one for completed
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? notifications.count : 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? "PENDING" : "COMPLETED"
    }

    //Load the data into the table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as? NotificationTableViewCell else {
            fatalError("Something's wrong with the Order object!")
        }

        let notifSnapshot = notifications[indexPath.row]
        guard let notification = notifSnapshot.value as? [String: Any] else { return cell }

        let title = notification["title"] as? String ?? ""
        let name = notification["acceptName"] as? String ?? ""
        let cost = notification["points"] as! Double
        
        cell.userImage.image = #imageLiteral(resourceName: "DefaultAvatar")
        cell.personalMessage.text = title
        cell.notificationLabel.text = name + " requests " + String(cost) + " points for completing your request!"

        cell.payButton.tag = indexPath.row
        cell.payButton.addTarget(self, action: #selector(self.completeTransaction), for: UIControlEvents.touchUpInside)

        return cell
    }

    @objc func completeTransaction(button : UIButton) {
        performServerTransaction(selectedRequest: notifications[button.tag])
    }

    // Segue preparation
    private func performServerTransaction(selectedRequest : DataSnapshot) {
        // Delete the order from both accept and request of acceptedOrders
        // Move the order to completed
        // Increment accept userId by point value and decrement request userId by point value
        
    }

    // Server Call
    private func listenNotifications() {
        // accepted orders filter
        
        UserUtil.getCurrentUserName() { userName in
            UserUtil.getCurrentCircle() { circle in
                let orderRef = self.ref.child("acceptedOrders/request/\(circle)/\(userName)")
                
                self._acceptAddHandle = orderRef.observe(.childAdded, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    strongSelf.notifications.append(snapshot)
                    strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.notifications.count-1, section: 0)], with: .automatic)
                })
                self._acceptRemoveHandle = orderRef.observe(.childRemoved, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    
                    if let index = strongSelf.notifications.index(where: {$0.key == snapshot.key}) {
                        strongSelf.notifications.remove(at: index)
                        strongSelf.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                })
            }
        }
    }
}


