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
