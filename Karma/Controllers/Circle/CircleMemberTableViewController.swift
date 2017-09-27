//
//  CircleMemberTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/21/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CircleMemberTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.lightGray
        
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
            fatalError("Something's wrong with the Circle object!")
        }
        
        let member = members[indexPath.row]
        cell.nameLabel.text = member.name! as String
        
        //TODO: This should become a query on requesting user id and then a pull on their image attribute
        let profilePicture = UIImage(named: "DummyAvatar")
        cell.userImage.image = profilePicture!.maskInCircle(image: profilePicture!, radius: 78)
        
        cell.layer.borderWidth = 10.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }
    
    private func loadMembers() {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless!.data.of(Circle.ofClass())
        let currentUser = backendless!.userService.currentUser
        
        let loadRelationsQueryBuilder = LoadRelationsQueryBuilder.of(BackendlessUser.ofClass())
        loadRelationsQueryBuilder!.setRelationName("Users")
        
        let circleId = currentUser!.getProperty("circleId") as! String
        
        members = dataStore!.loadRelations(circleId, queryBuilder: loadRelationsQueryBuilder) as! [BackendlessUser]
        
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
    
}
