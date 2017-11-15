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
    
    var currentUserId: String?
    var currentUserName: String?
    var selectedUserId: String
    var selectedUserName: String?
    
    var completed : Bool = false
    var cost : Double = 0.0
    
    override init () {
        self.currentUserId = ""
        self.currentUserName = ""
        self.selectedUserId = ""
        self.selectedUserName = ""
    }
    
    init (currentUser : BackendlessUser, selectedUser : BackendlessUser) {
        self.currentUserId = currentUser.name! as String
        self.currentUserName = currentUser.objectId! as String
        self.selectedUserId = selectedUser.name! as String
        self.selectedUserName = selectedUser.objectId! as String
    }
    
}
