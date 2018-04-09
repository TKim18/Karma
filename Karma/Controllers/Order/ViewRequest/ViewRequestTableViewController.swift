//
//  ViewRequestTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/1/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ViewRequestTableViewController: UITableViewController {

    // Local Variables
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    let cellSpacingHeight: CGFloat = 5
    let backgroundColor = UIColor.white
    
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
        self.storageRef = Storage.storage().reference()
        
        //Set up connection to database
        configureDatabase()
        
        //Display number of points
        configureKarmaPoints()
        
        //Configure the view
        configureTableView()
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
        self.tableView.backgroundColor = UIColor(red: 242, green: 242, blue: 242)
        
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
        cell.backgroundColor = backgroundColor
    }
    
    //Load the data into the table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ViewRequestTableViewCell", for: indexPath) as? ViewRequestTableViewCell else {
            fatalError("Something's wrong with the Order object!")
        }

        let orderSnapshot = self.orders[indexPath.row]
        guard let order = orderSnapshot.value as? [String: Any], let info = order["info"] as? [String: Any], let reqUser = order["requestUser"] as? [String: Any] else { return cell }
        
        let title = info[Constants.Order.Fields.title] as? String
        let cost = info[Constants.Order.Fields.points] as! Double
        let requestId = reqUser["id"] as? String ?? ""
        
        cell.titleLabel.text = title! //+ " for $" + String(describing: cost)
        cell.pointsLabel.text = String(describing: cost)
        //cell.descriptionLabel.text = info[Constants.Order.Fields.details] as? String
        //cell.timeLabel.text = info[Constants.Order.Fields.time] as? String
        //cell.locationLabel.text = info[Constants.Order.Fields.destination] as? String
        cell.categoryImage.image = Order.Category.Custom.image
        
        UserUtil.getProperty(key: "photoURL", id: requestId) { imageString in
            let imageString = imageString as? String ?? "default"
            let imageURL = URL(string: imageString)
            let imagePath = imageURL?.path
            
            if imagePath == "default" {
                cell.userImage.image = #imageLiteral(resourceName: "DefaultAvatar")
            } else {
                ImageCache.default.retrieveImage(forKey: requestId, options: nil) {
                    image, cacheType in
                    if let image = image {
                        cell.userImage.image = image
                    } else {
                        self.storageRef.child(imagePath!).getData(maxSize: INT64_MAX) {(data, error) in
                            if let error = error {
                                print(error.localizedDescription)
                                cell.userImage.image = #imageLiteral(resourceName: "DefaultAvatar")
                            } else {
                                DispatchQueue.main.async {
                                    let serverImage = UIImage.init(data: data!)
                                    cell.userImage.image = serverImage
                                    self.saveImageToCache(image: serverImage!, id: requestId)
                                    cell.setNeedsLayout()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    private func saveImageToCache(image: UIImage, id: String) {
        ImageCache.default.store(image, forKey: id)
    }
    
    // Slide to accept or delete request
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let snapshot = self.orders[indexPath.row]
        guard var order = snapshot.value as? [String: Any], let reqUser = order["requestUser"] as? [String: Any] else { return [] }
        
        let userId = UserUtil.getCurrentId() ?? ""
        
        // When viewing unaccepted orders
        if self.pendingAcceptedControl.selectedSegmentIndex == 0 {
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                Order.deleteUnaccept(key: snapshot.key)
            }
            delete.backgroundColor = .red
            
            let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                Order.uploadAccept(key: snapshot.key, val: order, userId: userId)
            }
            accept.backgroundColor = UIColor(rgb: 0x32CD32)
            
            return (reqUser["id"] as? String ?? "" == userId) ? [delete] : [accept]
        } else {
            let unaccept = UITableViewRowAction(style: .normal, title: "Undo") { action, index in
                Order.undoAccept(orderSnapshot: snapshot)
            }
            unaccept.backgroundColor = .red
            
            return [unaccept]
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Prepare for More Details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let selectedCircleCell = sender as? ViewRequestTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for : selectedCircleCell) else {
            fatalError("You definitely got the wrong cell")
        }
        
        let orderSnapshot = orders[indexPath.row]
        guard let order = orderSnapshot.value as? [String: Any] else { return }
        
        if let destination = segue.destination as? OrderDetailsViewController {
            destination.currentOrder = orders[indexPath.row]
        }
    }
    
    deinit {
        if let userId = UserUtil.getCurrentId() {
            UserUtil.getCurrentUserName() { userName in
                UserUtil.getCurrentCircle() { circle in
                    let pointRef = self.ref.child("users/\(userId)")
                    let unacceptRef = self.ref.child("unacceptedOrders/\(circle)")
                    let acceptRef = self.ref.child("acceptedOrders/accept/\(circle)/\(userName)")
                    
                    if let pointHandle = self._pointHandle {
                        pointRef.removeObserver(withHandle: pointHandle)
                    }
                    if let unacceptAddHandle = self._unacceptAddHandle {
                        unacceptRef.removeObserver(withHandle: unacceptAddHandle)
                    }
                    if let unacceptRemoveHandle = self._unacceptRemoveHandle {
                        unacceptRef.removeObserver(withHandle: unacceptRemoveHandle)
                    }
                    if let acceptAddHandle = self._unacceptAddHandle {
                        acceptRef.removeObserver(withHandle: acceptAddHandle)
                    }
                    if let acceptRemoveHandle = self._unacceptRemoveHandle {
                       acceptRef.removeObserver(withHandle: acceptRemoveHandle)
                    }
                }
            }
        }
    }
}
