//
//  OrderDetailsView.swift
//  Karma
//
//  Created by Isaac Son on 4/8/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit
import Firebase

class OrderDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        presentOrder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentOrder() {
        guard let order = currentOrder.value as? [String: Any], let info = order["info"] as? [String: Any], let _ = order["requestUser"] as? [String: Any] else { return }
        
        let title = info[Constants.Order.Fields.title] as? String
        let cost = info[Constants.Order.Fields.points] as! Double
        
        descriptionTextView.text = info[Constants.Order.Fields.details] as? String ?? ""
        timeLabel.text = info[Constants.Order.Fields.time] as? String ?? ""
        locationLabel.text = info[Constants.Order.Fields.destination] as? String ?? ""
        pointsLabel.text = String(describing: cost)
        titleLabel.text = title!
        //userLabel.text = reqUser["name"] as? String ?? ""

    }
    
    @IBAction func dismissModal(sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    //Local Variables
    var currentOrder : DataSnapshot!
    
    //UI Elements
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    //@IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
