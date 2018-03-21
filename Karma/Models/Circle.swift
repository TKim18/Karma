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
    func upload(newCircle: Bool, callback: @escaping () -> ()) {
        let ref = Database.database().reference()
        
        if let id = UserUtil.getCurrentId() {
            UserUtil.getProperty(key: "userName", id: id) { userName in
                if let userName = userName, let circleName = self.joinName, let circleKey = self.joinKey {
                    if newCircle {
                        var data : [String : Any]
                        data = [:]
                        data["joinName"] = circleName
                        data["displayName"] = circleName
                        data["joinKey"] = circleKey
                        ref.child("circles/\(circleName)").setValue(data)
                    }
                    ref.child("circles/\(circleName)/members/\(userName)").setValue(true)
                    ref.child("users/\(id)/circles/\(circleName)").setValue(true)
                } else {
                    print("Unable to retrieve user property")
                }
                callback()
            }
        }
    }
    
    // Check if the circle already exists on the database
    func exists(completionHandler: @escaping(_ exist: Bool) -> ()) {
        let ref = Database.database().reference()
        if let name = self.joinName {
            ref.child("circles").child(name).observeSingleEvent(of: .value, with: { (snapshot) in
                let entity = snapshot.value as? NSDictionary
                let val = entity == nil ? false : true
                completionHandler(val)
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    // Authenticate the circle with its password
    func existsWithKey(completionHandler: @escaping(_ exist: Bool) -> ()) {
        let ref = Database.database().reference()
        if let name = self.joinName {
            ref.child("circles").child(name).observeSingleEvent(of: .value, with: { (snapshot) in
                let entity = snapshot.value as? NSDictionary
                if let entity = entity, let joinName = self.joinName, let joinKey = self.joinKey, let name = entity["joinName"], let password = entity["joinKey"] {
                    let name = name as! String
                    let password = password as! String
                    completionHandler(name == joinName && password == joinKey)
                } else {
                    completionHandler(false)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    static func getCircleDataStore() -> IDataStore {
        return Backendless.sharedInstance().data.of(Circle().ofClass())
    }
    
}
