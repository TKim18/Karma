//
//  UserHelper.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 10/12/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class UserUtil {
    
    static func getCurrentUserFB() -> User {
        return Auth.auth().currentUser!
    }
    
    static func getCurrentId() -> String? {
        return getCurrentUserFB().uid
    }
    
    static func getCurrentEmail() -> String? {
        return getCurrentUserFB().email
    }
    
    static func getCurrentCircle(completionHandler: @escaping (_ circle: String) -> ()) {
        getCurrentProperty(key: "circles") { circles in
            let entity = circles as? NSDictionary ?? [:]
            let val = entity.allKeys.first as? String ?? ""
            completionHandler(val)
        }
    }
    
    static func getCurrentUserName(completionHandler: @escaping (_ userName: String) -> ()) {
        getCurrentProperty(key: "userName") { userName in
            let val = userName as? String ?? ""
            completionHandler(val)
        }
    }
    
    static func getCurrentProperty(key: String, completionHandler: @escaping (_ prop: Any?) -> ()) {
        let userId = getCurrentId()
        if let userId = userId {
            getProperty(key: key, id: userId, completionHandler: completionHandler)
        }
    }
    
    static func getProperty(key: String, id: String, completionHandler: @escaping (_ prop: Any?) -> ()) {
        let ref = Database.database().reference()
        ref.child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let entity = snapshot.value as? NSDictionary
            if let entity = entity {
                let val = entity[key]
                completionHandler(val)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    static func transactPoints(snapshot: DataSnapshot) {
        if let order = snapshot.value as? [String: Any] {
            let points = order["points"] as! Double
            let requestId = order["userId"] as? String ?? ""
            let acceptId = order["acceptId"] as? String ?? ""
            
            movePoints(userId: requestId, op: "sub", points: points)
            movePoints(userId: acceptId, op: "add", points: points)
        }
    }
    
    static func movePoints(userId: String, op: String, points: Double) {
        let ref = Database.database().reference().child("users/\(userId)/karma")
        ref.runTransactionBlock({(currentData: MutableData) -> TransactionResult in
            if var karma = currentData.value as? Double {
                (op == "add") ? (karma += points) : (karma -= points)
                currentData.value = karma
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        })
    }
 
    static func getCurrentUser() -> BackendlessUser {
        return Backendless.sharedInstance().userService.currentUser
    }
    
    static func getCurrentUserProperty(key: String) -> Any {
        return getCurrentUser().getProperty(key)
    }
    
    static func getUserDataStore() -> IDataStore {
        return Backendless.sharedInstance().data.of(BackendlessUser.ofClass())
    }
    
    static func getUserWithId(userId: String) -> BackendlessUser {
        let userDataStore = getUserDataStore()
        return userDataStore.find(byId: userId) as! BackendlessUser
    }
    
    static func getUserProperty(key: String, userId: String) -> Any {
        return getUserWithId(userId: userId).getProperty(key)
    }
    
    static func getCurrentUserId() -> String {
        return getCurrentUser().objectId as String
    }
    
    static func getCurrentUserName() -> String {
        return getCurrentUser().name as String
    }
}
