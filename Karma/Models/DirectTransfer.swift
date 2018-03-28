//
//  DirectTransfer.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation
import FirebaseDatabase

@objcMembers
class DirectTransfer : NSObject {
    
    var objectId : String?
    var title : String?
    
    var currentUserId: String?
    var currentUserName: String?
    var currentName: String?
    var selectedUserId: String
    var selectedUserName: String?
    var selectedName: String?
    
    var completed : Bool = false
    var cost : Double = 0.0
    
    override init () {
        self.title = ""
        self.currentUserId = ""
        self.currentUserName = ""
        self.currentName = ""
        self.selectedUserId = ""
        self.selectedUserName = ""
        self.selectedName = ""
    }
    
    init (currentUserId: String, currentUserName: String, currentName: String, selectedUserId: String, selectedUserName: String, selectedName: String) {
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.currentName = currentName
        self.selectedUserId = selectedUserId
        self.selectedUserName = selectedUserName
        self.selectedName = selectedName
    }
    
    static func getDTDataStore() -> IDataStore {
        return Backendless.sharedInstance().data.of(DirectTransfer().ofClass())
    }
    
    func upload() {
        
    }
    
    func performPay(callback: @escaping () -> ()) {
        let ref = Database.database().reference()
        
    }
    
}
