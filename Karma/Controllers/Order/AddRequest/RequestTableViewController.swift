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
        
        //Customize these... please
        //self.title = "Choose your category"
        //navigationController?.navigationBar.barTintColor = UIColor.blue
        //navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var categories = Order.Category.allCategories

    // MARK: - Table view data source

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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let selectedCircleCell = sender as? RequestCategoryTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for : selectedCircleCell) else {
            fatalError("You definitely got the wrong cell")
        }
        
        let backendless = Backendless.sharedInstance()!
        let currentCategory = categories[indexPath.row]
        let currentUser = backendless.userService.currentUser
        
        //Going to have to change this around for different views depending on category
        if segue.identifier == "ShowRequestDetails" {
            if let destination = segue.destination as? CustomRequestViewController {
                let currentOrder = Order(
                    category: currentCategory,
                    requestingUserId: currentUser!.objectId as String,
                    requestingUserName: currentUser!.name as String,
                    circleId: currentUser?.getProperty("circleId") as! String)
                destination.currentOrder = currentOrder
            }
        }
    }

}
