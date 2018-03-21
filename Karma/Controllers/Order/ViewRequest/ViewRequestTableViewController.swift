//
//  ViewRequestTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/1/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class ViewRequestTableViewController: UITableViewController {

    // Local Variables
    var ref: DatabaseReference!
    let cellSpacingHeight: CGFloat = 5
    fileprivate var _refHandle: DatabaseHandle?
    var orders: [DataSnapshot]! = []
    
    private let refreshCont = UIRefreshControl()
    
    // UIElements
    @IBOutlet weak var pendingAcceptedControl: UISegmentedControl!
    @IBOutlet weak var karmaPointsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView.register(ViewRequestTableViewCell.self, forCellReuseIdentifier: "ViewRequestCell")
        
        //Set up connection to database
        configureDatabase()
        
        //Pull from the database
        //loadAllOrders()
        
        //Configure the view
        configureTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Pull from the database
        //loadAllOrders()

        //Show no orders picture if orders is empty
        //noOrders()

        //Configure the navigation bar
        //updateKarmaPoints()
    }
    
    deinit {
        if let refHandle = _refHandle {
            self.ref.child("order").removeObserver(withHandle: refHandle)
        }
    }
    
    private func configureDatabase() {
        loadUnaccepted()
        loadAccepted()
    }
    
    private func configureTableView() {
        //Configure background color
        self.tableView.backgroundColor = UIColor.lightGray
        
        //Enable segment control
        self.pendingAcceptedControl.addTarget(self, action: #selector(self.segmentChanged), for: .valueChanged)
        
        //Enable pull to refresh
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshCont
        } else {
            tableView.addSubview(refreshCont)
        }
        refreshCont.addTarget(self, action: #selector(self.refreshOrders), for: .valueChanged)
        refreshCont.attributedTitle = NSAttributedString(string: "Fetching new orders ...")
    }

    @objc private func refreshOrders(_sender : Any) {
        self.tableView.reloadData()
        self.refreshCont.endRefreshing()
    }
    
    private func updateKarmaPoints() {
        
    }
    

    @objc func segmentChanged(sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//            case 0: loadPending()
//            case 1: loadAccepted()
//            default: self.orders = []
//        }
        self.tableView.reloadData()
    }

    //--------------------------------- Pull Order Data -------------------------------------//
    
    private func loadUnaccepted() {
        ref = Database.database().reference().child("unacceptedOrders")
        UserUtil.getCurrentCircle() { circle in
            self.ref.child(circle).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
                guard let strongSelf = self else { return }
                strongSelf.orders.append(snapshot)
                
                // TODO: Add conditional to check which segmented control it is
                strongSelf.tableView.insertRows(at: [IndexPath(row: 0, section: strongSelf.orders.count-1)], with: .automatic)
            })
        }
    }
    
    private func loadAccepted() {
        
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ViewRequestTableViewCell", for: indexPath) as? ViewRequestTableViewCell else {
            fatalError("Something's wrong with the Order object!")
        }
        
        let orderSnapshot = self.orders[indexPath.section]
        guard let order = orderSnapshot.value as? [String: String] else { return cell }
    
        cell.titleLabel.text = order[Constants.Order.Fields.title] ?? ""
        cell.descriptionLabel.text = order[Constants.Order.Fields.description] ?? ""
        cell.timeLabel.text = order[Constants.Order.Fields.time] ?? ""
        cell.locationLabel.text = order[Constants.Order.Fields.location] ?? ""
        cell.categoryImage.image = Order.fromDescription(description: order[Constants.Order.Fields.category] ?? "").image
        cell.userImage.image = UIImage(named: "DefaultAvatar")!
        
        return cell
    }
}
