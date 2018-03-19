//
//  CircleTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/24/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CircleTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load the circles!
        loadCircles()
        
    }

    // Server call
    private func loadCircles() {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless!.data.of(Circle.ofClass())
        let allCircles = dataStore!.find() as! [Circle]
        
        circles = allCircles
    }
    
    // MARK: - Table view data source
    var circles = [Circle]()
    
    // Configure Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return circles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CircleTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CircleTableViewCell else {
            fatalError("Something's wrong with the Circle object!")
        }
        
        let circle = circles[indexPath.row]
        cell.nameLabel.text = circle.displayName
        
        return cell
    }

    //Segue Handling
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if validAccept(indexPath: indexPath as NSIndexPath) {
//            orders.remove(at: indexPath.section)
//            self.tableView.reloadData()
//        }
//    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return (validCircle(sender: sender) && identifier == "JoinCircle")
    }
        
    func validCircle(sender: Any?) -> Bool {
        guard let selectedCircleCell = sender as? CircleTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for : selectedCircleCell) else {
            fatalError("You definitely got the wrong cell")
        }
        
        let backendless = Backendless.sharedInstance()!
        let dataStore = backendless.data.of(Circle().ofClass())
        
        let currentUser = UserUtil.getCurrentUser()
        let selectedCircleId = circles[indexPath.row].objectId
        
        var status = true
        
        Types.tryblock({ () -> Void in
            //Update the User's circleId
            currentUser.updateProperties(["circleId" : selectedCircleId!])
            backendless.userService.update(currentUser)
            
            //And also add user to circle's Users column
            dataStore!.addRelation(
                "Users",
                parentObjectId: selectedCircleId,
                childObjects: [currentUser.objectId]
            )
        }, catchblock: {(exception) -> Void in
            print(exception ?? "Error")
            status = false
        })
        return status
    }
}
