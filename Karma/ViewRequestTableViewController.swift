//
//  ViewRequestTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/1/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class ViewRequestTableViewController: UITableViewController {

    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewDidLoad()
        loadOrders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    var orders = [Order]()

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ViewRequestTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ViewRequestTableViewCell else {
            fatalError("Something's wrong with the Order object!")
        }
        
        let order = orders[indexPath.row]
        cell.titleLabel.text = order.title
        cell.descriptionLabel.text = order.message
        
        //cell.timeLabel.text = order.created
        cell.timeLabel.text = "6:00 PM"
        cell.locationLabel.text = order.origin! + " to " + order.destination!
        
        //This should become a query on requesting user id and then a pull on their image attribute
        cell.userImage.image = UIImage(named: "DummyAvatar")
        cell.categoryImage.image = order.fromDescription(description: order.category!).image
        
        return cell
    }
    
    //Server call
    private func loadOrders() {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless!.data.of(Order().ofClass())
        
        let currentCircle = backendless!.userService.currentUser.getProperty("circleId") as! String
        
        //TODO: Please use the update query code when backendless gets around to it
        let queryClause = "circleId = '" + currentCircle + "'"
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setWhereClause(queryClause)
        
        Types.tryblock({() -> Void in
            self.orders = dataStore!.find(queryBuilder) as! [Order]
        },
        catchblock: { (exception) -> Void in
            let error = exception as! Fault
            print(error)
        })
        
        
        // let loadRelationsQueryBuilder = LoadRelationsQueryBuilder.init(with: Circle().ofClass())
        // loadRelationsQueryBuilder!.setGetRelationName("Orders")
        // let queryBuilder = DataQueryBuilder()
        // queryBuilder!.setRelated(["Orders", "Orders.title"])
        
//        loadRelationsQueryBuilder!.setGetPageSize(5)
//        loadRelationsQueryBuilder!.setGetOffset(10)
//
//        Types.tryblock({ () -> Void in
//            dataStore?.loadRelations(
//                currentCircle,
//                queryBuilder: loadRelationsQueryBuilder
//            )
//        },
//            catchblock: { (exception) -> Void in
//            let error = exception as! NSException
//            print(error)
//        })
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
