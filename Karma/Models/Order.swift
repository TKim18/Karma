//
//  Request.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/25/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation
import UIKit

import FirebaseDatabase

@objcMembers
class Order : NSObject {
    
    enum Category: String {
        case Summerfields, WesWings, WeShop, Custom
        
        static let allCategories = [Summerfields, WesWings, WeShop, Custom]
        
        var description: String {
            switch self {
            case .Summerfields: return "Summerfields"
            case .WesWings: return "WesWings"
            case .WeShop: return "WeShop"
            case .Custom: return "Custom"
            }
        }
        
        var image: UIImage {
            switch self {
            case .Summerfields: return UIImage(named: "Summerfields")!
            case .WesWings: return UIImage(named: "WeShop")!
            case .WeShop: return UIImage(named: "WeShop")!
            case .Custom: return UIImage(named: "Summerfields")!
            }
        }
    }

    var title : String?
    var details : String?
    var time : String?
    var category : Category?
    var destination : String?
    var cost : Double = 0.0
    
    override init () {
        self.title = ""
        self.details = ""
        self.time = ""
        self.category = .Custom
        self.destination = ""
    }
    
    // Add an unaccepted order
    func upload(callback: @escaping () -> ()) {
        let ref = Database.database().reference()
        
        if let userId = UserUtil.getCurrentId() {
            UserUtil.getCurrentProperty(key: "name") { name in
                UserUtil.getCurrentUserName() { userName in
                    UserUtil.getCurrentCircle() { circleName in
                        if let title = self.title, let details = self.details, let time = self.time, let category = self.category, let destination = self.destination {
                            // Separate order information from user information
                            let specifics = [
                                Constants.Order.Fields.title : title,
                                Constants.Order.Fields.details : details,
                                Constants.Order.Fields.time : time,
                                Constants.Order.Fields.category : category.description,
                                Constants.Order.Fields.destination : destination,
                                Constants.Order.Fields.points : self.cost
                                ] as [String : Any]
                            
                            let userInfo = [
                                "id" : userId,
                                "userName" : userName,
                                "name" : name as? String ?? ""
                            ] as [String: Any]
                            
                            let data = ["info" : specifics, "requestUser": userInfo]
                            
                            // Save under the corresponding circle for unacceptedOrders
                            ref.child("unacceptedOrders/\(circleName)").childByAutoId().setValue(data)
                        } else {
                            print("Unable to retrieve all of the order properties")
                        }
                        callback()
                    }
                }
            }
        }
    }
    
    // A user accepts another user's request
    static func uploadAccept(key: String, val: [String: Any], userId: String) {
        let ref = Database.database().reference()
        UserUtil.getCurrentUserName() { userName in
            UserUtil.getCurrentCircle() { circleName in
                UserUtil.getCurrentProperty(key: "name") { name in
                    var order = val
                    guard let reqUser = order["requestUser"] as? [String : Any] else { return }
                    if let requestName = reqUser["userName"] {
                        // Delete the request from the list of unaccepted orders
                        ref.child("unacceptedOrders/\(circleName)/\(key)").removeValue()
                 
                        // Add the request under the name of the person who accepted it
                        let acceptRef = ref.child("acceptedOrders/accept/\(circleName)/\(userName)").childByAutoId()
                        
                        // Add the details of who accepted the order to the request
                        order["acceptUser"] = [
                            "id" : userId,
                            "userName" : userName,
                            "name" : name as? String ?? ""
                        ]
                        
                        acceptRef.setValue(order)
                        
                        // Keep track of the mirroring order
                        order["autoId"] = acceptRef.key
                        order["isDirect"] = "false"
                        
                        // Add the request under the name of the person who requested it
                        ref.child("acceptedOrders/request/\(circleName)/\(requestName)").childByAutoId().setValue(order)
                    }
                }
            }
        }
    }
    
    // The original requesting user has paid off the person who accepted
    static func completeRequest(orderSnapshot: DataSnapshot) {
        let ref = Database.database().reference()
        
        UserUtil.getCurrentCircle() { circleName in
            let key = orderSnapshot.key
            guard var order = orderSnapshot.value as? [String: Any], let reqUser = order["requestUser"] as? [String : Any], let accUser = order["acceptUser"] as? [String : Any] else { return }
            
            // Pull some user information to get the right database path
            let requestUserName = reqUser["userName"] as? String ?? ""
            let acceptUserName = accUser["userName"] as? String ?? ""
            let autoId = order["autoId"] as? String ?? ""
            
            // Indicate this was not a direct transfer for transaction history purposes and remove id
            order["autoId"] = nil
            
            // Make mirroring completed receipts for transaction history
            ref.child("acceptedOrders/request/\(circleName)/\(requestUserName)/\(key)").removeValue()
            ref.child("acceptedOrders/accept/\(circleName)/\(acceptUserName)/\(autoId)").removeValue()
            ref.child("completedOrders/\(circleName)/\(requestUserName)").childByAutoId().setValue(order)
            ref.child("completedOrders/\(circleName)/\(acceptUserName)").childByAutoId().setValue(order)
        }
    }
}
