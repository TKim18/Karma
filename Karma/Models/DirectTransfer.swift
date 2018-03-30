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
    
    var title : String?
    var cost : Double = 0.0
    
    var currentUserId: String?
    var currentUserName: String?
    var currentName: String?
    var selectedUserId: String
    var selectedUserName: String?
    var selectedName: String?
    
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
    
    func performRequest(callback: @escaping () -> ()) {
        let ref = Database.database().reference()
        UserUtil.getCurrentCircle() { circleName in
            if let requestId = self.currentUserId, let requestName = self.currentName, let requestUserName = self.currentUserName, let acceptName = self.selectedName, let acceptUserName = self.selectedUserName, let title = self.title {
                
                let reqUser = [
                    "id" : self.selectedUserId,
                    "name" : acceptName,
                    "userName" : acceptUserName
                ] as [String : Any]
                
                let accUser = [
                    "id" : requestId,
                    "name": requestName,
                    "userName": requestUserName
                ] as [String : Any]
                
                let info = [
                    "title" : title,
                    "points" : self.cost
                ] as [String : Any]
                
                let order = [
                    "acceptUser" : accUser,
                    "requestUser" : reqUser,
                    "info" : info,
                    "isDirect" : "true"
                ] as [String : Any]
                
                ref.child("acceptedOrders/request/\(circleName)/\(acceptUserName)").childByAutoId().setValue(order)
                callback()
            }
        }
    }
    
    func performPay(callback: @escaping () -> ()) {
        if let requestId = self.currentUserId, let requestName = self.currentUserName, let acceptName = self.selectedUserName {
            UserUtil.transactPoints(points: self.cost, requestId: requestId, requestName: requestName, acceptId: self.selectedUserId, acceptName: acceptName)
            callback()
        }
    }
    
}
