//
//  RequestTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/26/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class RequestTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
    }

    var categories = Order.Category.allCategories

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RequestCategoryTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RequestCategoryTableViewCell else {
            fatalError("Something's wrong with the Request object!")
        }
        
        let category = categories[indexPath.row]
        cell.categoryLabel.text = category.description
        cell.categoryImage.image = category.image
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let selectedCircleCell = sender as? RequestCategoryTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for : selectedCircleCell) else {
            fatalError("You definitely got the wrong cell")
        }
        
        let currentCategory = categories[indexPath.row]
        let currentUser = UserUtil.getCurrentUser()
        
        //Going to have to change this around for different views depending on category
        if segue.identifier == "ShowRequestDetails" {
            if let destination = segue.destination as? CustomRequestViewController {
                let currentOrder = Order(
                    category: currentCategory,
                    requestingUserId: currentUser.objectId as String,
                    requestingUserName: currentUser.name as String)
                destination.currentOrder = currentOrder
            }
        }
    }

}
