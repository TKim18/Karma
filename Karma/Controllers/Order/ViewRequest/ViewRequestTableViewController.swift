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

        //Pull from the database
        loadAllOrders()
        
        //Configure the view
        configureTableView()
        
        //Configure the navigation bar
        inititalizeNavBar()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
    
    // UIElements
    @IBOutlet weak var pendingAcceptedControl: UISegmentedControl!
    
    // MARK: - Table view data source
    private var allOrders = [Order]()
    private var orders = [Order]()
    
    private func configureTableView() {
        //Configure background color
        self.tableView.backgroundColor = UIColor.lightGray
        
        //Enable segment control
        self.pendingAcceptedControl.addTarget(self, action: #selector(self.segmentChanged), for: .valueChanged)
    }
    
    private func inititalizeNavBar() {
        //Navbar color: #285398
        self.navigationController?.navigationBar.barTintColor = UIColor(rgb: 285398)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let backendless = Backendless.sharedInstance()!
        let currentUsersPoints = backendless.userService.currentUser.getProperty("karmaPoints") as! Double
        
        let button = UIButton.init(type: .custom)
        
        let rightShift = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        rightShift.width = -10;
        
        let karmaIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        karmaIcon.image = UIImage(named: "KarmaPointsIcon")
        let karmaPoints = UILabel(frame : CGRect(x: 35, y: 0, width: 50, height: 30))
        karmaPoints.text = String(currentUsersPoints)
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 30))
        button.frame = buttonView.frame
        
        buttonView.addSubview(button)
        buttonView.addSubview(karmaIcon)
        buttonView.addSubview(karmaPoints)
        
        let barButton = UIBarButtonItem.init(customView: buttonView)
        //self.navigationItem.rightBarButtonItem = barButton
    
        //let barItem : UIBarButtonItem = UIImage(named:"KarmaPointsIcon")!.withRenderingMode(.alwaysOriginal)
        
        // self.navigationItem.rightBarButtonItems = [rightShift, barButton]

    }
    
    @objc func segmentChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0: loadPending()
            case 1: loadAccepted()
            default: self.orders = []
        }
        self.tableView.reloadData()
    }

    private func loadAllOrders() {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless!.data.of(Circle.ofClass())
        let circleId = backendless!.userService.currentUser.getProperty("circleId") as! String

        let loadRelationsQueryBuilder = LoadRelationsQueryBuilder.of(Order.ofClass())
        loadRelationsQueryBuilder!.setRelationName("Orders")
        
        Types.tryblock({() -> Void in
            self.allOrders = dataStore!.loadRelations(circleId, queryBuilder: loadRelationsQueryBuilder) as! [Order]
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
    
    //Load the data into the table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "ViewRequestTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ViewRequestTableViewCell else {
            fatalError("Something's wrong with the Order object!")
        }
        
        let order = orders[indexPath.section]
        
        //Cell text components
        cell.titleLabel.text = order.title
        cell.descriptionLabel.text = order.message
        cell.timeLabel.text = order.requestedTime
        cell.locationLabel.text = order.origin! + " to " + order.destination!
        cell.categoryImage.image = order.fromDescription().image
        
        //TODO: This should become a query on requesting user id and then a pull on their image attribute
        let profilePicture = UIImage(named: "DummyAvatar")
        cell.userImage.image = profilePicture!.maskInCircle(image: profilePicture!, radius: 78)
        
        return cell
    }

    ///---------------------- Accepting a request handling ---------------------------//
    
    //At some point, make this a swipe rather than a click
//    @IBAction func acceptRequest(sender : AnyObject){
//        self.performSegue(withIdentifier: "AcceptRequest", sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        //Check for mess ups
        guard let selectedOrderCell = sender as? ViewRequestTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for : selectedOrderCell) else {
            fatalError("You definitely got the wrong cell")
        }
        
        let dataStore = Order.getOrderDataStore()
        let currentUser = User.getCurrentUser()
        
        let selectedOrder = orders[indexPath.row]
        
        //TODO: Move this to a shouldPerformSegue rather than a prepare
        if (selectedOrder.requestingUserId == (currentUser.objectId as String)) { return }
        
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
    }
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
// Synchronous Call:
//        Types.tryblock({ () -> Void in
//            //Update the Order object to reflect the acceptingUserId
//
//        }, catchblock: {(exception) -> Void in
//            print(exception ?? "Error")
//        })
