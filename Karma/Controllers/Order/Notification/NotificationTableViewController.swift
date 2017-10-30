//
//  RespondRequestTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/26/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController {

    //TODO: ENABLE PUSH NOTIFICATIONS
    var notifications = [Order]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadNotifications();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let cellIdentifier = "NotificationTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotificationTableViewCell else {
            fatalError("Something's wrong with the Order object!")
        }
        
        let notification = notifications[indexPath.row]
        
        cell.notificationLabel.text = notification.acceptingUserName! + " requests " + String(notification.cost) + " points for completing your request!"
        cell.personalMessage.text = notification.title
        
        //TODO: This should become a query on requesting user id and then a pull on their image attribute
        let profilePicture = UIImage(named: "DummyAvatar")
        cell.userImage.image = profilePicture!.maskInCircle(image: profilePicture!, radius: 78)
        //cell.payButton.addTarget(self, action: #selector(self.completeTransaction), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
//    @objc func completeTransaction(button : UIButton) {
//        self.performSegue(withIdentifier: "CompleteTransaction", sender: button)
//    }
    
    // Segue preparation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "CompleteTransaction") {
            let indexPath : NSIndexPath
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! UITableViewCell
                indexPath = self.tableView.indexPath(for: cell)! as NSIndexPath
                
                return performServerTransaction(selectedRequest: notifications[indexPath.row])
            }
            return false;
        }
        return false;
    }
    
    private func performServerTransaction(selectedRequest : Order) -> Bool {
        let userService = Backendless.sharedInstance().userService
        let orderDataStore = Order.getOrderDataStore()
        
        // Set the current request to be completed
        selectedRequest.completed = true;
        orderDataStore.save(
            selectedRequest,
            response: {
                (updatedRequest) -> () in
                print("Completed the request")
        },
            error: {
                (fault : Fault?) -> () in
                print("Something went wrong trying to complete the request: \(String(describing: fault))")
        })
        
        // Update the people's karma points according to their service
        let acceptingUser = User.getUserWithId(userId: selectedRequest.acceptingUserId!)
        let requestingUser = User.getCurrentUser()
        
        let currentAccept = acceptingUser.getProperty("karmaPoints") as! Double
        let currentRequest = requestingUser.getProperty("karmaPoints") as! Double
        
        let cost = (selectedRequest.cost).rounded(toPlaces: 2)
        
        let newAccept = Double(currentAccept + cost).rounded(toPlaces: 2)
        let newRequest = Double(currentRequest - cost).rounded(toPlaces: 2)
        
        acceptingUser.setProperty("karmaPoints", object: newAccept)
        requestingUser.setProperty("karmaPoints", object: newRequest)
        
        var status = false
        
        Types.tryblock({() -> Void in
            userService!.update(acceptingUser)
            userService!.update(requestingUser)
            status = true
        },
           catchblock: { (exception) -> Void in
            let error = exception as! Fault
            print(error)
        })
        
        return status
    }

    // Server Call
    private func loadNotifications() {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless!.data.of(Circle.ofClass())
        
        let loadRelationsQueryBuilder = LoadRelationsQueryBuilder.of(Order.ofClass())
        loadRelationsQueryBuilder!.setRelationName("Orders")
        loadRelationsQueryBuilder!.setPageSize(20)
        
        // Filter down all orders to include just the current user's requests
        // that have been accepted by someone else but not yet completed
        Types.tryblock({() -> Void in
            let allOrders = dataStore!.loadRelations(
                User.getCurrentUserProperty(key: "circleId") as! String,
                queryBuilder: loadRelationsQueryBuilder
            ) as! [Order]
            self.notifications = allOrders.filter {
                !($0.completed) &&
                $0.acceptingUserId != "-1" &&
                $0.requestingUserId == User.getCurrentUserId()
            }
            self.notifications.sort { return ($0.updated! as Date) < ($1.updated! as Date) }
        },
           catchblock: { (exception) -> Void in
                let error = exception as! Fault
                print(error)
        })
    }
}
