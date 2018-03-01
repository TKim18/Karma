//
//  ViewRequestTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/1/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import Kingfisher

class ViewRequestTableViewController: UITableViewController {

    // Local Variables
    let cellSpacingHeight: CGFloat = 5
    private var allOrders = [Order]()
    private var orders = [Order]()
    
    // UIElements
    @IBOutlet weak var pendingAcceptedControl: UISegmentedControl!
    @IBOutlet weak var karmaPointsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Pull from the database
        loadAllOrders()
        
        //Configure the view
        configureTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        //Pull from the database
        loadAllOrders()
    
        //Show no orders picture if orders is empty
        noOrders()
        
        //Configure the navigation bar
        updateKarmaPoints()
    }
    
    private func noOrders() {
        if (orders.isEmpty) {
            let backgroundImage = UIImage(named: "NoOrders")
            self.tableView.backgroundView = UIImageView(image: backgroundImage)
        }
    }
    
    private func configureTableView() {
        //Configure background color
        self.tableView.backgroundColor = UIColor.lightGray
        
        //Enable segment control
        self.pendingAcceptedControl.addTarget(self, action: #selector(self.segmentChanged), for: .valueChanged)
    }

    private func updateKarmaPoints() {
        karmaPointsButton.title = String(User.getCurrentUserProperty(key: "karmaPoints") as! Double)
    }

    @objc func segmentChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0: loadPending()
            case 1: loadAccepted()
            default: self.orders = []
        }
        self.tableView.reloadData()
    }

    //--------------------------------- Pull Order Data -------------------------------------//
    
    private func loadAllOrders() {
        let dataStore = Circle.getCircleDataStore()
        let circleId = User.getCurrentUserProperty(key: "circleId") as! String

        let loadRelationsQueryBuilder = LoadRelationsQueryBuilder.of(Order.ofClass())
        loadRelationsQueryBuilder!.setRelationName("Orders")
        loadRelationsQueryBuilder!.setPageSize(20)
        
        Types.tryblock({() -> Void in
            self.allOrders = dataStore.loadRelations(circleId, queryBuilder: loadRelationsQueryBuilder) as! [Order]
            //Sort all the orders by their created date
            self.allOrders.sort { return ($0.created! as Date) < ($1.created! as Date) }
            self.loadPending()
        },
            catchblock: { (exception) -> Void in
            let error = exception as! Fault
            print(error)
        })
    }
    
    private func loadPending() {
        self.orders = self.allOrders.filter { $0.acceptingUserId == "-1" }
    }
    
    private func loadAccepted() {
        self.orders = self.allOrders.filter {
            $0.acceptingUserId == User.getCurrentUserId() && !$0.completed
        }
    }

    //---------------------- Setting the table elements and variables ---------------------------//
    
    //Each order has its own section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return orders.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 0 : cellSpacingHeight
    }
    
    //Set the table insides as white
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
//    func loadUserImage(id : String) -> UIImage {
//        let imagePath = User.getUserWithId(userId: id).getProperty("imagePath") as! String
//
//        let url = URL(string: imagePath)
//        DispatchQueue.global().async {
//            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//            DispatchQueue.main.async {
//                self.imageView.image = UIImage(data: data!)
//            }
//        }
//    }
    
    //Load the data into the table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "ViewRequestTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ViewRequestTableViewCell else {
            fatalError("Something's wrong with the Order object!")
        }
        
        let order = orders[indexPath.section]
        
        //Cell text components
        cell.titleLabel.text = order.title! + " for $" + String(order.cost)
        cell.descriptionLabel.text = order.message
        cell.timeLabel.text = order.requestedTime
        //TODO: Make this location label depend on whether both fields have a value or not
        cell.locationLabel.text = order.destination!
        cell.categoryImage.image = order.fromDescription().image
        
        //TODO: This should become a query on requesting user id and then a pull on their image attribute
        let imagePath = User.getUserWithId(userId: order.requestingUserId!).getProperty("imagePath") as! String
        
        if imagePath == "default" {
            cell.userImage.image = UIImage(named: "DefaultAvatar")
        }
        else {
            let url = URL(string: imagePath)
            cell.userImage.kf.setImage(with: url)
        }
        
        // cell.userImage.image = profilePicture!.maskInCircle(image: profilePicture!, radius: 78)
        
        return cell
    }

    ///---------------------- Accepting a request handling ---------------------------//
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if validAccept(indexPath: indexPath as NSIndexPath) {
            orders.remove(at: indexPath.section)
            self.tableView.reloadData()
        }
    }

    func validAccept(indexPath: NSIndexPath) -> Bool {
        let dataStore = Order.getOrderDataStore()
        let currentUser = User.getCurrentUser()
        
        let selectedOrder = orders[indexPath.section]
        
        if (selectedOrder.requestingUserId == (currentUser.objectId as String)
         || selectedOrder.acceptingUserId == (currentUser.objectId as String)) { return false }
        
        selectedOrder.acceptingUserId = currentUser.objectId as String
        selectedOrder.acceptingUserName = currentUser.name as String
        
        dataStore.save(
            selectedOrder,
            response: {
                (order) -> () in
                print("Order saved")
            },
            error: {
                (fault : Fault?) -> () in
                print("Server reported an error: \(String(describing: fault))")
            }
        )
        
        return true;
    }
  
//    var valid = false;
//
//    Types.tryblock({ () -> Void in
//    dataStore.save(selectedOrder)
//    valid = true
//    }, catchblock: {(exception) -> Void in
//    print(exception ?? "Error")
//    })

}

// Asynchronous Call:
//        dataStore!.loadRelations(
//            circleId,
//            queryBuilder: loadRelationsQueryBuilder,
//            response: { pulledOrders in
//                self.allOrders = pulledOrders as! [Order]
//                self.loadPending()
//            },
//            error: {
//                fault in
//                print("Server reported an error: \(fault!.message)")
//            }
//        )
