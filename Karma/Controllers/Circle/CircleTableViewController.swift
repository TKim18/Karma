//
//  CircleTableViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/24/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CircleTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load the circles!
        loadCircles()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    var circles = [Circle]()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return circles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CircleTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CircleTableViewCell else {
            fatalError("Something's wrong with the Circle object!")
        }
        
        let circle = circles[indexPath.row]
        cell.nameLabel.text = circle.displayName
        
        return cell
    }

    //Segue Handling
    @IBAction func showMain(sender : AnyObject){
        self.performSegue(withIdentifier: "RegisterToCircle", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let selectedCircleCell = sender as? CircleTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for : selectedCircleCell) else {
            fatalError("You definitely got the wrong cell")
        }
        
        let backendless = Backendless.sharedInstance()!
        let dataStore = backendless.data.of(Circle().ofClass())

        let currentUser = User.getCurrentUser()
        let selectedCircleId = circles[indexPath.row].objectId

        Types.tryblock({ () -> Void in
            //Update the User's circleId
            currentUser.updateProperties(["circleId" : selectedCircleId!])
            backendless.userService.update(currentUser)
            
            //And also add user to circle's Users column
            dataStore!.addRelation(
                "Users",
                parentObjectId: selectedCircleId,
                childObjects: [currentUser.objectId]
            )
        }, catchblock: {(exception) -> Void in
            print(exception ?? "Error")
        })
    }
    
    //Server call
    private func loadCircles() {
        let backendless = Backendless.sharedInstance()
        let dataStore = backendless!.data.of(Circle.ofClass())
        let allCircles = dataStore!.find() as! [Circle]
        
        circles = allCircles
    }

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
    
}
