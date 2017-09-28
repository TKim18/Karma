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
    override func viewDidLoad() {
        super.viewDidLoad()

        loadNotifications();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    var notifications = [Order]()

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
        //return notifications.count
    }
    
    private func loadNotifications() {
        //For any particular user, we want to get all the orders of their circle
        //And from all those orders, we want to get all those that have requestingUserId as the user
        //So now we have all the user's requests, and then filter those down to those that have an
        //AcceptingUserId that is not -1. and then filter those down to those that have completed = false
        
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
            self.notifications = allOrders.filter {
                $0.requestingUserId == (currentUser!.objectId! as String) && $0.acceptingUserId != "-1"
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
