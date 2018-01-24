//
//  Circle.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/22/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

@objcMembers
class Circle : NSObject {
    
    var objectId : String?
    let name : String?
    let password : String?
    var displayName : String?
    
    override init () {
        self.name = ""
        self.password = ""
        self.displayName = ""
    }
    
    init (name: String, password: String) {
        self.name = name
        self.password = password
        self.displayName = name
    }
    
    static func getCircleDataStore() -> IDataStore {
        return Backendless.sharedInstance().data.of(Circle().ofClass())
    }
    
}
