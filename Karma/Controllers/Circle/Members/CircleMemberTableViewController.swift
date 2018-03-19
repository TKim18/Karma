//
//  CircleMemberTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit
import Kingfisher

class CircleMemberTableViewController: UITableViewController {

    let viewColor = UIColor(red: 242, green: 242, blue: 242)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = viewColor
        self.tableView.separatorColor = viewColor
        
        // Load data
        loadMembers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    var members = [BackendlessUser]()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CircleMemberTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CircleMemberTableViewCell else {
            fatalError("Something's wrong with the Circle Member object!")
        }
        
        let member = members[indexPath.row]
        cell.nameLabel.text = member.name! as String
        cell.costLabel.text = String(member.getProperty("karmaPoints") as! Double)
        
        let memberId = member.objectId! as String
        let imagePath = member.getProperty("imagePath") as! String
        if imagePath == "default" {
            cell.userImage.image = UIImage(named: "DefaultAvatar")!
        }
        else {
            ImageCache.default.retrieveImage(forKey: memberId, options: nil) {
                image, cacheType in
                if let image = image {
                    cell.userImage.image = image
                } else {
                    let url = URL(string: imagePath)
                    cell.userImage.kf.setImage(with: url, completionHandler: {
                        (image, error, cacheType, imageUrl) in
                        self.saveImageToCache(image: image!, id: memberId)
                    })
                }
            }
        }
        
        cell.layer.borderWidth = 10.0
        cell.layer.borderColor = viewColor.cgColor
        
        if (indexPath.row == 0) {
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    private func saveImageToCache (image: UIImage, id: String) {
        ImageCache.default.store(image, forKey: id)
    }
    
    private func loadMembers() {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless!.data.of(Circle.ofClass())
        
        let loadRelationsQueryBuilder = LoadRelationsQueryBuilder.of(BackendlessUser.ofClass())
        loadRelationsQueryBuilder!.setRelationName("Users")
        
        let circleId = UserUtil.getCurrentUserProperty(key: "circleId") as! String
        
        members = dataStore!.loadRelations(circleId, queryBuilder: loadRelationsQueryBuilder) as! [BackendlessUser]
        
        let userId = UserUtil.getCurrentUserId()
        let currIndex = members.index(where: {($0.objectId as String) == userId })
       
        // Make the current user to be the first on the list
        let temp = members[0]
        members[0] = members[currIndex!]
        members[currIndex!] = temp
        
        
        //Asynchronous call:
        //        dataStore!.loadRelations(
        //            circleId,
        //            queryBuilder: loadRelationsQueryBuilder,
        //            response: { members in
        //                self.members = members as! [BackendlessUser]
        //            },
        //            error: { fault in
        //                print("Server reported an error: \(fault!.message)")
        //            }
        //        )
    }
    
    // In preparation for direct transferring
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let selectedCircleCell = sender as? CircleMemberTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for : selectedCircleCell) else {
            fatalError("You definitely got the wrong cell")
        }
        
        let selectedUser = members[indexPath.row]
        
        if let destination = segue.destination as? DirectTransferViewController {
            let currentTransfer = DirectTransfer(
                currentUser : UserUtil.getCurrentUser(),
                selectedUser : selectedUser)
            destination.currentTransfer = currentTransfer
        }
    }
    
    
}
