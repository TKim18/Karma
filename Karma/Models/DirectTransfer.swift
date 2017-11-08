//
//  DirectTransfer.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

class DirectTransfer : NSObject {
    
    var objectId : String?
    var title : String?
    
    var requestingUser : BackendlessUser
    var acceptingUser : BackendlessUser
    
    var completed : Bool = false
    var cost : Double = 0.0
    
    override init () {
        self.requestingUser = User.getCurrentUser()
        self.acceptingUser = User.getCurrentUser()
    }
    
    
    init (requestingUser : BackendlessUser, acceptingUser : BackendlessUser) {
        self.requestingUser = requestingUser
        self.acceptingUser = acceptingUser
    }
    
}
