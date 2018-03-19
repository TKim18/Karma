//
//  Circle.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/22/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation
import FirebaseDatabase

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
    
    // In an upload call, add the circle name as the key and members/display name as values
    func upload() {
        let ref = Database.database().reference()
        let userName = UserUtil.getCurrentProperty(key: "userName") as? String
        if let userName = userName {
            ref.child("circles/\(self.joinName as Optional)/displayName").setValue(self.joinName)
            ref.child("circles/\(self.joinName as Optional)/members/\(userName)").setValue(true)
            // Add circle to user object
            // ref.child("users/\()")
        } else {
            print("Unable to retrieve user property")
        }
    }
    
    // Check if the circle already exists on the database
    func exists() -> Bool {
        let ref = Database.database().reference()
        var status = false
        if let name = self.joinName {
            ref.child("circles").child(name).observeSingleEvent(of: .value, with: { (snapshot) in
                status = true
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        return status
    }
    
    static func getCircleDataStore() -> IDataStore {
        return Backendless.sharedInstance().data.of(Circle().ofClass())
    }
    
}
