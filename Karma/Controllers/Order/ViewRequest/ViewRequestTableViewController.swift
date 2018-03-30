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
    fileprivate var _unacceptAddHandle: DatabaseHandle?
    fileprivate var _unacceptRemoveHandle: DatabaseHandle?
    fileprivate var _acceptAddHandle: DatabaseHandle?
    fileprivate var _acceptRemoveHandle: DatabaseHandle?
    
    var orders: [DataSnapshot]! = []
    var unacceptOrders: [DataSnapshot]! = []
    var acceptOrders: [DataSnapshot]! = []
    
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
        if let pointHandle = _pointHandle {
            self.ref.child("users").removeObserver(withHandle: pointHandle)
        }
        if let unacceptAddHandle = _unacceptAddHandle {
            self.ref.child("unacceptedOrder").removeObserver(withHandle: unacceptAddHandle)
        }
        if let unacceptRemoveHandle = _unacceptRemoveHandle {
            self.ref.child("unacceptedOrder").removeObserver(withHandle: unacceptRemoveHandle)
        }
    }
    
    private func configureDatabase() {
        listenUnaccepted()
        listenAccepted()
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
        //Set the initial orders to be unaccepted
        self.orders = self.unacceptOrders
        
        //Configure background color
        self.tableView.backgroundColor = UIColor.lightGray
        
        //Enable segment control
        self.pendingAcceptedControl.addTarget(self, action: #selector(self.segmentChanged), for: .valueChanged)
        if pendingAcceptedControl.selectedSegmentIndex == 1 {
            tableView.allowsSelection = false
        }
        
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
        switch sender.selectedSegmentIndex {
            case 0: self.orders = self.unacceptOrders
            case 1: self.orders = self.acceptOrders
            default: self.orders = []
        }
        self.tableView.reloadData()
    }

    //--------------------------------- Pull Order Data -------------------------------------//
    
    private func listenUnaccepted() {
        UserUtil.getCurrentCircle() { circle in
            let orderRef = self.ref.child("unacceptedOrders/\(circle)")
            
            self._unacceptAddHandle = orderRef.observe(.childAdded, with: {
                [weak self] (snapshot) -> Void in
                guard let strongSelf = self else { return }
                strongSelf.unacceptOrders.append(snapshot)

                if strongSelf.pendingAcceptedControl.selectedSegmentIndex == 0 {
                    strongSelf.orders.append(snapshot)
                    strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.unacceptOrders.count-1, section: 0)], with: .automatic)
                }
            })
            self._unacceptRemoveHandle = orderRef.observe(.childRemoved, with: {
                [weak self] (snapshot) -> Void in
                guard let strongSelf = self else { return }
                
                if let index = strongSelf.unacceptOrders.index(where: {$0.key == snapshot.key}) {
                    strongSelf.unacceptOrders.remove(at: index)
                    
                    if strongSelf.pendingAcceptedControl.selectedSegmentIndex == 0 {
                        strongSelf.orders.remove(at: index)
                        strongSelf.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
            })
        }
    }
    
    private func listenAccepted() {
        UserUtil.getCurrentUserName() { userName in
            UserUtil.getCurrentCircle() { circle in
                let orderRef = self.ref.child("acceptedOrders/accept/\(circle)/\(userName)")
                
                self._acceptAddHandle = orderRef.observe(.childAdded, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    strongSelf.acceptOrders.append(snapshot)
                
                    if strongSelf.pendingAcceptedControl.selectedSegmentIndex == 1 {
                        strongSelf.orders.append(snapshot)
                        strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.acceptOrders.count-1, section: 0)], with: .automatic)
                    }
                })
                self._acceptRemoveHandle = orderRef.observe(.childRemoved, with: {
                    [weak self] (snapshot) -> Void in
                    guard let strongSelf = self else { return }
                    
                    if let index = strongSelf.acceptOrders.index(where: {$0.key == snapshot.key}) {
                        strongSelf.acceptOrders.remove(at: index)
                        
                        if strongSelf.pendingAcceptedControl.selectedSegmentIndex == 1 {
                            strongSelf.orders.remove(at: index)
                            strongSelf.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        }
                    }
                })
            }
        }
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
        guard let order = orderSnapshot.value as? [String: Any], let info = order["info"] as? [String: Any], let _ = order["requestUser"] else { return cell }
        
        let title = info[Constants.Order.Fields.title] as? String
        let cost = info[Constants.Order.Fields.points] as! Double
        
        cell.titleLabel.text = title! + " for $" + String(describing: cost)
        cell.descriptionLabel.text = info[Constants.Order.Fields.details] as? String
        cell.timeLabel.text = info[Constants.Order.Fields.time] as? String
        cell.locationLabel.text = info[Constants.Order.Fields.destination] as? String
        cell.categoryImage.image = Order.Category.Custom.image
        cell.userImage.image = #imageLiteral(resourceName: "DefaultAvatar")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let snapshot = self.orders[indexPath.row]
        guard var order = snapshot.value as? [String: Any], let reqUser = order["requestUser"] as? [String: Any] else { return [] }
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("told to delete")
        }
        delete.backgroundColor = .red
        
        let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
            print("told to accept")
        }
        accept.backgroundColor = .green
        
        if let userId = UserUtil.getCurrentId() {
            if reqUser["id"] as? String ?? "" == userId {
                return [delete]
            } else {
                return [accept]
            }
        }
        
        return [delete, accept]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    ///---------------------- Accepting a request handling ---------------------------//
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: do different things depending on state of segment control
        
        let snapshot = self.orders[indexPath.row]
        guard var order = snapshot.value as? [String: Any], let reqUser = order["requestUser"] as? [String: Any] else { return }
        
        if let userId = UserUtil.getCurrentId() {
            if reqUser["id"] as? String ?? "" == userId { return }
            Order.uploadAccept(key: snapshot.key, val: order, userId: userId)
        }
    }
}
