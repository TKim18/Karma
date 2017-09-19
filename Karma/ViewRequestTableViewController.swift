//
//  ViewRequestTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/1/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class ViewRequestTableViewController: UITableViewController {

    let cellSpacingHeight: CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //pendingAcceptedControl.addTarget(self, action: Selector("segmentChanged:"), for: .valueChanged)
        loadAllOrders()
        pendingAcceptedControl.addTarget(self, action: #selector(self.segmentChanged), for: .valueChanged)

        // #285398
        //navigationController?.navigationBar.barTintColor = UIColor()
       //navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 28.0/255.0, green: 53.0/255.0, blue: 98.0/255.0, alpha: 1.0)
        //navigationController?.navigationBar.barTintColor = UIColor(rgb: 0x285398)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UIElements
    @IBOutlet weak var pendingAcceptedControl: UISegmentedControl!

    // MARK: - Table view data source
    private var allOrders = [Order]()
    private var orders = [Order]()
    
    func segmentChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        //If Pending is selected, we want to show the subset of orders that have accepting userId of -1
        case 0:
            loadPending()
        case 1:
            loadAccepted()
        default:
            self.orders = []
        }
        self.tableView.reloadData()
    }

    //Server call
    private func loadAllOrders() {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless!.data.of(Order().ofClass())
        
        let currentCircle = backendless!.userService.currentUser.getProperty("circleId") as! String
        
        //TODO: Please use the update query code when backendless gets around to it
        //TODO: Update orders to exclude the orders that you placed (maybe)
        let queryClause = "circleId = '" + currentCircle + "'"
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(queryClause)
        
        Types.tryblock({() -> Void in
            self.allOrders = dataStore!.find(queryBuilder) as! [Order]
            self.orders = self.allOrders
        },
                       catchblock: { (exception) -> Void in
                        let error = exception as! Fault
                        print(error)
        })
    }
    
    private func loadPending() {
        self.orders = []
        for request in self.allOrders {
            if (request.acceptingUserId == "-1") {
                self.orders.append(request)
            }
        }
    }
    
    private func loadAccepted() {
        self.orders = []
        let backendless = Backendless.sharedInstance()!
        let currentUserId = backendless.userService.currentUser.objectId
        for request in self.allOrders {
            if (request.acceptingUserId == (currentUserId! as String)) {
                self.orders.append(request)
            }
        }
    }

    //---------------------- Setting the table elements and variables ---------------------------// 
    override func numberOfSections(in tableView: UITableView) -> Int {
        return orders.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.gray
        return headerView
    }

    // Load the data into the table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ViewRequestTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ViewRequestTableViewCell else {
            fatalError("Something's wrong with the Order object!")
        }
        
        let order = orders[indexPath.section]
        
        // Fill in cell's data components
        cell.titleLabel.text = order.title
        cell.descriptionLabel.text = order.message
        
        //cell.timeLabel.text = order.created
        cell.timeLabel.text = order.requestedTime
        cell.locationLabel.text = order.origin! + " to " + order.destination!
        
        cell.categoryImage.image = order.fromDescription().image
        
        // TODO: This should become a query on requesting user id and then a pull on their image attribute
        let profilePicture = UIImage(named: "DummyAvatar")
        cell.userImage.image = profilePicture!.maskInCircle(image: profilePicture!, radius: 78)

        //Customize its border
        //cell.layer.borderWidth = 2.0
        //cell.layer.borderColor = UIColor.gray.cgColor
        
        return cell
    }

}
