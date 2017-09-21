//
//  Request.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/25/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

class Order : NSObject {
    
    enum Category: String {
        case Summerfields, WesWings, WeShop, Custom
        
        static let allCategories = [Summerfields, WesWings, WeShop, Custom]
        
        init?(id : Int) {
            switch id {
            case 1:
                self = .Summerfields
            case 2:
                self = .WesWings
            case 3:
                self = .WeShop
            case 4:
                self = .Custom
            default:
                return nil
            }
        }
        
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
    var acceptingUserId: String?
    let circleId : String?
    
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
        self.cost = 0.0
        self.circleId = "-1"
        self.requestingUserId = "-1"
        self.acceptingUserId = "-1"
    }
    
    //Probably only going to use this one
    init (category: Category, requestingUserId: String, circleId: String) {
        self.category = category.description
        self.requestingUserId = requestingUserId
        self.circleId = circleId
    }
    
    //Not sure if necessary
    init (title: String, message: String, requestedTime: String, category: Category, origin: String, destination: String, cost: Double, circleId: String, requestingUserId: String, acceptingUserId: String) {
        self.title = title
        self.message = message
        self.requestedTime = requestedTime
        self.category = category.description
        self.origin = origin
        self.destination = destination
        self.cost = cost
        self.circleId = circleId
        self.requestingUserId = requestingUserId
        self.acceptingUserId = acceptingUserId
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