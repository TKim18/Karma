//
//  Order.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/25/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

class Order : NSObject {
    
    enum Category: String {
        case Food, Laundry, Shopping, Custom
        
        static let allCategories = [Food, Laundry, Shopping, Custom]
        
        var description: String {
            switch self {
            case .Food: return "Food"
            case .Laundry: return "Laundry"
            case .Shopping: return "Shopping"
            case .Custom: return "Custom"
            }
        }
        
        var image: UIImage {
            switch self {
            case .Food: return UIImage(named: "Dummy")!
            case .Laundry: return UIImage(named: "Dummy")!
            case .Shopping: return UIImage(named: "Dummy")!
            case .Custom: return UIImage(named: "Dummy")!
            }
        }
        
        init?(id : Int) {
            switch id {
            case 1:
                self = .Food
            case 2:
                self = .Laundry
            case 3:
                self = .Shopping
            case 4:
                self = .Custom
            default:
                return nil
            }
        }
    }
    
    var objectId : String?
    var requestingUserId: String?
    var acceptingUserId: String?
    let circleId : String?
    
    var title : String?
    var message : String?
    var category : Category? //Maybe I want this to be :String for serializing more easily
    var origin : String?
    var destination : String?
    var cost : Double = 0.0
    
    override init () {
        self.title = ""
        self.message = ""
        self.category = Category.Custom
        self.origin = ""
        self.destination = ""
        self.cost = 0.0
        self.circleId = "-1"
        self.requestingUserId = "-1"
        self.acceptingUserId = "-1"
    }
    
    //Probably only going to use this one
    init (category: Category, requestingUserId: String, circleId: String) {
        self.category = category
        self.requestingUserId = requestingUserId
        self.circleId = circleId
    }
    
    //Not sure if necessary
    init (title: String, message: String, category: Category, origin: String, destination: String, cost: Double, circleId: String, requestingUserId: String, acceptingUserId: String) {
        self.title = title
        self.message = message
        self.category = category
        self.origin = origin
        self.destination = destination
        self.cost = cost
        self.circleId = circleId
        self.requestingUserId = requestingUserId
        self.acceptingUserId = acceptingUserId
    }
    
}
