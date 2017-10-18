//
//  UserHelper.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 10/12/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

class User {
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
