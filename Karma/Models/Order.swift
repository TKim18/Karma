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
        case Summerfields, WesWings, WeShop, RedBlack, PiCafe, Custom
        
        static let allCategories = [WesWings, WeShop, Summerfields, PiCafe, RedBlack, Custom]
        
        init(text: String) {
            switch text {
            case "Summerfields": self = .Summerfields
            case "WesWings": self = .WesWings
            case "WeShop": self = .WeShop
            case "Red & Black": self = .RedBlack
            case "Pi Cafe": self = .PiCafe
            default: self = .Custom
            }
        }
        
        var description: String {
            switch self {
            case .Summerfields: return "Summerfields"
            case .WesWings: return "WesWings"
            case .WeShop: return "WeShop"
            case .RedBlack: return "Red & Black"
            case .PiCafe: return "Pi Cafe"
            case .Custom: return "Custom"
            }
        }
        
        var image: UIImage {
            switch self {
            case .Summerfields: return UIImage(named: "summies")!
            case .WesWings: return UIImage(named: "swings")!
            case .WeShop: return UIImage(named: "weshop")!
            case .RedBlack: return UIImage(named: "rednblack")!
            case .PiCafe: return UIImage(named: "picafe")!
            case .Custom: return UIImage(named: "custom")!
            }
        }
        
        var brightImage: UIImage {
            switch self {
            case .Summerfields: return UIImage(named: "summiesbright")!
            case .WesWings: return UIImage(named: "weswingsbright")!
            case .WeShop: return UIImage(named: "weshopbright")!
            case .RedBlack: return UIImage(named: "rednblackbright")!
            case .PiCafe: return UIImage(named: "picafebright")!
            case .Custom: return UIImage(named: "custombright")!
            }
        }
        
        var menuURL: URL {
            switch self {
            case .Summerfields: return URL(string: "https://docs.wixstatic.com/ugd/5b7235_ef544eac449b4dce92e4a4f935e78d46.pdf")!
            case .WesWings: return URL(string: "https://drive.google.com/file/d/1GSyRmZwwNtkR8ZvuLYj34ebqUfgsLhc6/view")!
            case .RedBlack: return URL(string: "https://docs.wixstatic.com/ugd/5b7235_71a4a9824d95417ea8999a547b86b911.pdf")!
            case .PiCafe: return URL(string: "https://docs.wixstatic.com/ugd/5b7235_585fdd97d4884f708a9d6bf5d7958b10.pdf")!
            case .WeShop: return URL(string: "www.google.com")!
            case .Custom: return URL(string: "www.google.com")!
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
    
    init (category: Category) {
        self.title = ""
        self.details = ""
        self.time = ""
        self.category = category
        self.destination = ""
    }
    
    // Add an unaccepted order
    func upload(callback: @escaping () -> ()) {
        let ref = Database.database().reference()
        
        if let userId = UserUtil.getCurrentId() {
            UserUtil.getCurrentProperty(key: "name") { name in
                UserUtil.getCurrentUserName() { userName in
                    UserUtil.getCurrentCircle() { circleName in
                        UserUtil.getCurrentImageURL() { url in
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
                                
                                PushNotification.notifyNewRequest(title: title)
                            } else {
                                print("Unable to retrieve all of the order properties")
                            }
                            callback()
                        }
                    }
                }
            }
        }
    }
    
    // Remove the user's order from the list of unaccepted
    static func deleteUnaccept(key: String) {
        let ref = Database.database().reference()
        UserUtil.getCurrentCircle() { circleName in
            ref.child("unacceptedOrders/\(circleName)/\(key)").removeValue()
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
                    if let requestName = reqUser["userName"] as? String {
                        // Delete the request from the list of unaccepted orders
                        ref.child("unacceptedOrders/\(circleName)/\(key)").removeValue()
                        
                        // Add the request under the name of the person who accepted it
                        let acceptRef = ref.child("acceptedOrders/accept/\(circleName)/\(userName)").childByAutoId()
                        let requestRef = ref.child("acceptedOrders/request/\(circleName)/\(requestName)").childByAutoId()
                        
                        // Add the details of who accepted the order to the request
                        order["acceptUser"] = [
                            "id" : userId,
                            "userName" : userName,
                            "name" : name as? String ?? ""
                        ]
                        
                        // Set the mirroring order/request id for deletion purposes
                        order["autoId"] = requestRef.key
                        acceptRef.setValue(order)

                        order["autoId"] = acceptRef.key
                        order["isDirect"] = "false"
                        requestRef.setValue(order)
                        
                        PushNotification.notifyAcceptRequest(name: name as! String, topic: requestName)
                    }
                }
            }
        }
    }
    
    // The person who accepted decides they cannot
    static func undoAccept(orderSnapshot: DataSnapshot) {
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
            ref.child("acceptedOrders/accept/\(circleName)/\(acceptUserName)/\(key)").removeValue()
            ref.child("acceptedOrders/request/\(circleName)/\(requestUserName)/\(autoId)").removeValue()
            ref.child("unacceptedOrders/\(circleName)").childByAutoId().setValue(order)
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
    
    static func rejectRequest(orderSnapshot: DataSnapshot) {
        let ref = Database.database().reference()
        
        UserUtil.getCurrentCircle() { circleName in
            let key = orderSnapshot.key
            guard var order = orderSnapshot.value as? [String: Any], let reqUser = order["requestUser"] as? [String : Any], let accUser = order["acceptUser"] as? [String : Any] else { return }
            
            // Pull some user information to get the right database path
            let requestUserName = reqUser["userName"] as? String ?? ""
            let acceptUserName = accUser["userName"] as? String ?? ""
            let autoId = order["autoId"] as? String ?? ""
            
            // Make mirroring completed receipts for transaction history
            ref.child("acceptedOrders/request/\(circleName)/\(requestUserName)/\(key)").removeValue()
            ref.child("acceptedOrders/accept/\(circleName)/\(acceptUserName)/\(autoId)").removeValue()
        }
    }
}
