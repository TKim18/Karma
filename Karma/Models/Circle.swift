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
    let joinName : String?
    let joinKey : String?
    var displayName : String?
    
    override init () {
        self.joinName = ""
        self.joinKey = ""
        self.displayName = ""
    }
    
    init (name: String, password: String) {
        self.joinName = name
        self.joinKey = password
        self.displayName = name
    }
    
    static func getCircleDataStore() -> IDataStore {
        return Backendless.sharedInstance().data.of(Circle().ofClass())
    }
    
}
