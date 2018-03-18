//
//  Request.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/25/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation
import UIKit

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
    var message : String?
    var requestedTime : String?
    var category : String?
    var origin : String?
    var destination : String?
    var cost : Double = 0.0
    
    override init () {
        self.title = ""
        self.message = ""
        self.requestedTime = ""
        self.category = ""
        self.origin = ""
        self.destination = ""
        self.requestingUserId = "-1"
        self.requestingUserName = "-1"
        self.acceptingUserId = "-1"
        self.acceptingUserName = "-1"
    }
    
    //Probably only going to use this one
    init (category: Category, requestingUserId: String, requestingUserName: String) {
        self.category = category.description
        self.requestingUserId = requestingUserId
        self.requestingUserName = requestingUserName
    }
    
    static func getOrderDataStore() -> IDataStore {
        return Backendless.sharedInstance().data.of(Order().ofClass())
    }

    func fromDescription() -> Category {
        switch self.description {
        case "Summerfields": return .Summerfields
        case "WesWings": return .WesWings
        case "WeShop": return .WeShop
        case "Custom": return .Custom
        default: return .Custom
        }
    }
    
}
