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
    }
    
    var objectId : String?
    
    let title : String?
    let message : String?
    let category : Category?
    let origin : String?
    let destination : String?
    var cost : Double = 0.0
    
    let circleId : String?
    
    override init () {
        self.title = ""
        self.message = ""
        self.category = Category.Custom
        self.origin = ""
        self.destination = ""
        self.cost = 0.0
        self.circleId = "-1"
    }
    
    init (title: String, message: String, category: Category, origin: String, destination: String, cost: Double, circleId: String) {
        self.title = title
        self.message = message
        self.category = category
        self.origin = origin
        self.destination = destination
        self.cost = cost
        self.circleId = circleId
    }
    
}
