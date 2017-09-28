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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    //Load the data into the table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "NotificationTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotificationTableViewCell else {
            fatalError("Something's wrong with the Order object!")
        }
        
        let notification = notifications[indexPath.row]
        
        cell.notificationLabel.text = notification.acceptingUserId! + "requests 10 pts for completing your request!"
        cell.personalMessage.text = notification.title
        
        //TODO: This should become a query on requesting user id and then a pull on their image attribute
        let profilePicture = UIImage(named: "DummyAvatar")
        cell.userImage.image = profilePicture!.maskInCircle(image: profilePicture!, radius: 78)
        
        return cell
    }
    
    //
    
    private func loadNotifications() {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless!.data.of(Circle.ofClass())
        let currentUser = backendless!.userService.currentUser
        let circleId = currentUser!.getProperty("circleId") as! String
        
        let loadRelationsQueryBuilder = LoadRelationsQueryBuilder.of(Order.ofClass())
        loadRelationsQueryBuilder!.setRelationName("Orders")
        
        Types.tryblock({() -> Void in
            let allOrders = dataStore!.loadRelations(
                circleId,
                queryBuilder: loadRelationsQueryBuilder
            ) as! [Order]
            //Filter down all orders to include just the current user's requests
            //That have been accepted by someone else but not yet completed
            self.notifications = allOrders.filter {
                $0.requestingUserId == (currentUser!.objectId! as String) &&
                $0.acceptingUserId != "-1" &&
                !($0.completed)
            }
        },
           catchblock: { (exception) -> Void in
                let error = exception as! Fault
                print(error)
        })
    }

//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let vw = UIView()
//        vw.backgroundColor = UIColor.red
//
//        return vw
//    }
    
 

}
