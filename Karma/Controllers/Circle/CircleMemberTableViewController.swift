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

        // Load members
        loadMembers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    var members = [BackendlessUser]()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return members.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    private func loadMembers() {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless!.data.of(Circle.ofClass())
        let currentUser = backendless!.userService.currentUser
        
        let loadRelationsQueryBuilder = LoadRelationsQueryBuilder.of(BackendlessUser.ofClass())
        loadRelationsQueryBuilder.setRelationName("Users")
        
        let circleId = currentUser!.getProperty("circleId") as! String
        
        members = dataStore.loadRelations(circleId, queryBuilder: loadRelationsQueryBuilder) as! [BackendlessUser]
    }
    
}
