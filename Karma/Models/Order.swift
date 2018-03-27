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
    
    var objectId : String?
    var created: NSDate?
    var updated: NSDate?
    
    var requestingUserId: String?
    var requestingUserName: String?
    var acceptingUserId: String?
    var acceptingUserName: String?
    
    var completed : Bool = false
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
        self.requestingUserId = "-1"
        self.requestingUserName = "-1"
        self.acceptingUserId = "-1"
        self.acceptingUserName = "-1"
    }
    
    func upload(callback: @escaping () -> ()) {
        let ref = Database.database().reference()
        
        if let userId = UserUtil.getCurrentId() {
            UserUtil.getCurrentUserName() { userName in
                UserUtil.getCurrentCircle() { circleName in
                    if let title = self.title, let details = self.details, let time = self.time, let category = self.category, let destination = self.destination {
                        var data : [String : Any]
                        data = [:]
                        data[Constants.Order.Fields.title] = title
                        data[Constants.Order.Fields.details] = details
                        data[Constants.Order.Fields.time] = time
                        data[Constants.Order.Fields.category] = category.description
                        data[Constants.Order.Fields.destination] = destination
                        data[Constants.Order.Fields.points] = self.cost
                        data[Constants.Order.Fields.userId] = userId
                        data[Constants.Order.Fields.userName] = userName
                        ref.child("unacceptedOrders/\(circleName)").childByAutoId().setValue(data)
                    } else {
                        print("Unable to retrieve all of the order properties")
                    }
                    callback()
                }
            }
        }
    }
    
    static func uploadAccept(key: String, val: [String: Any], userId: String) {
        let ref = Database.database().reference()
        UserUtil.getCurrentUserName() { userName in
            UserUtil.getCurrentCircle() { circleName in
                UserUtil.getCurrentProperty(key: "name") { name in
                    var order = val
                    if let requestName = order["userName"] {
                        ref.child("unacceptedOrders/\(circleName)/\(key)").removeValue()
                        
                        let acceptRef = ref.child("acceptedOrders/accept/\(circleName)/\(userName)").childByAutoId()
                        
                        order["acceptName"] = name as? String ?? ""
                        order["acceptUserName"] = userName
                        order["acceptId"] = userId
                        order["autoId"] = acceptRef.key
                        
                        ref.child("acceptedOrders/request/\(circleName)/\(requestName)").childByAutoId().setValue(order)
                        
                        order["userId"] = userId
                        order["userName"] = userName
                        order["acceptUserName"] = nil
                        order["acceptName"] = nil
                        order["acceptId"] = nil
                        order["autoId"] = nil
                        
                        acceptRef.setValue(order)
                    }
                }
            }
        }
    }
    
    static func completeRequest(orderSnapshot: DataSnapshot) {
        // Delete the order from both accept and request of acceptedOrders
        // Move the order to completed
        // orderSnapshot has:
        // accept id, accept name, accept user name
        // request id, request user name
        // autoid
        // category, destination, details, points, time, title
        // in deleting from the request that's east --> just delete from
        let ref = Database.database().reference()
        
        UserUtil.getCurrentCircle() { circleName in
            let key = orderSnapshot.key
            guard var order = orderSnapshot.value as? [String: Any] else { return }
            
            let requestUserName = order["userName"] as? String ?? ""
            let acceptUserName = order["acceptUserName"] as? String ?? ""
            let autoId = order["autoId"] as? String ?? ""
            
            ref.child("acceptedOrders/request/\(circleName)/\(requestUserName)/\(key)").removeValue()
            ref.child("acceptedOrders/accept/\(circleName)/\(acceptUserName)/\(autoId)").removeValue()
            ref.child("completedOrders/\(circleName)/\(requestUserName)").childByAutoId().setValue(order)
        }
    }
    
    static func getOrderDataStore() -> IDataStore {
        return Backendless.sharedInstance().data.of(Order().ofClass())
    }
    
}
