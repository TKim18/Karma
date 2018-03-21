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
    fileprivate var _pointHandle: DatabaseHandle?
    fileprivate var _unacceptHandle: DatabaseHandle?
    var orders: [DataSnapshot]! = []
    
    private let refreshCont = UIRefreshControl()
    
    // UIElements
    @IBOutlet weak var pendingAcceptedControl: UISegmentedControl!
    @IBOutlet weak var karmaPointsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        
        //Set up connection to database
        configureDatabase()
        
        //Display number of points
        configureKarmaPoints()
        
        //Configure the view
        configureTableView()
    }
    
    deinit {
        if let unacceptHandle = _unacceptHandle {
            self.ref.child("unacceptedOrder").removeObserver(withHandle: unacceptHandle)
        }
        if let pointHandle = _pointHandle {
            self.ref.child("users").removeObserver(withHandle: pointHandle)
        }
    }
    
    private func configureDatabase() {
        loadUnaccepted()
        loadAccepted()
    }
    
    private func configureKarmaPoints() {
        if let userId = UserUtil.getCurrentId() {
            let pointRef = self.ref.child("users/\(userId)/karma")
            self._pointHandle = pointRef.observe(DataEventType.value, with: { (snapshot) in
                let point = snapshot.value as! Double
                self.karmaPointsButton.title = String(point)
            })
        }
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
        UserUtil.getCurrentCircle() { circle in
            let orderRef = self.ref.child("unacceptedOrders/\(circle)")
            self._unacceptHandle = orderRef.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
                guard let strongSelf = self else { return }
                strongSelf.orders.append(snapshot)

                // TODO: Add conditional to check which segmented control it is
                strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.orders.count-1, section: 0)], with: .automatic)
            })
        }
    }
    
    private func loadAccepted() {
        
    }

    //---------------------- Setting the table elements and variables ---------------------------//
    
    //Each order has its own section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
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

        let orderSnapshot = self.orders[indexPath.row]
        guard let order = orderSnapshot.value as? [String: Any] else { return cell }
        
        let title = order[Constants.Order.Fields.title] as? String
        let cost = order[Constants.Order.Fields.points] as! Double
        
        cell.titleLabel.text = title! + " for $" + String(describing: cost)
        cell.descriptionLabel.text = order[Constants.Order.Fields.details] as? String
        cell.timeLabel.text = order[Constants.Order.Fields.time] as? String
        cell.locationLabel.text = order[Constants.Order.Fields.destination] as? String
        cell.categoryImage.image = Order.Category.Custom.image
        cell.userImage.image = #imageLiteral(resourceName: "DefaultAvatar")
        
        return cell
    }
}
