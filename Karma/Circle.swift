//
//  Circle.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/22/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

class Circle : NSObject {
    
    var objectId : String?
    let name : String
    var displayName : String?
    var Users : [BackendlessUser]
    
    override init () {
        self.name = ""
        self.displayName = ""
        self.Users = []
    }
    
    init (name: String) {
        self.name = name
        self.displayName = name
        self.Users = []
    }
    
    init (name : String, user: BackendlessUser) {
        self.name = name
        self.displayName = name
        self.Users = [user]
    }
}
