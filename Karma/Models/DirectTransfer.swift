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
    
    var requestingUserId: String?
    var requestingUserName: String?
    var acceptingUserId: String?
    var acceptingUserName: String?
    
    var completed : Bool = false
    var cost : Double = 0.0
    
    override init () {
        self.requestingUserId = ""
        self.requestingUserName = ""
        self.acceptingUserId = ""
        self.acceptingUserName = ""
    }
    
    init (requestingUser : BackendlessUser, acceptingUser : BackendlessUser) {
        self.requestingUserId = requestingUser.name! as String
        self.requestingUserName = requestingUser.objectId! as String
        self.acceptingUserId = acceptingUser.name! as String
        self.acceptingUserName = requestingUser.objectId! as String
    }
    
}
