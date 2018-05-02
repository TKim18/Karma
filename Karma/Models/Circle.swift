//
//  Circle.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/22/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation
import Firebase

@objcMembers
class Circle : NSObject {
    
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
    
    init (name: String) {
        self.joinName = name
        self.displayName = name
        self.joinKey = "-1"
    }
    
    static func getProperty(key: String, completionHandler: @escaping(_ prop: Any?) -> ()) {
        let ref = Database.database().reference()
        UserUtil.getCurrentCircle() { circleName in
            ref.child("circles").child(circleName).observeSingleEvent(of: .value, with: { (snapshot) in
                let entity = snapshot.value as? NSDictionary
                if let entity = entity {
                    let val = entity[key]
                    completionHandler(val)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    static func setProperty(key: String, value: String) {
        let ref = Database.database().reference()
        UserUtil.getCurrentCircle() { circleName in
            ref.child("circles/\(circleName)/\(key)").setValue(value)
        }
    }
    
    // In an upload call, add the circle name as the key and members/display name as values
    func upload(newCircle: Bool, callback: @escaping () -> ()) {
        let ref = Database.database().reference()
        
        if let id = UserUtil.getCurrentId() {
            UserUtil.getCurrentUserName() { userName in
                UserUtil.getCurrentProperty(key: "name") { name in
                    if let circleName = self.joinName, let circleKey = self.joinKey {
                        let cleanName = circleName.clean()
                        
                        if newCircle {
                            var data : [String : Any]
                            data = [:]
                            data["joinName"] = cleanName
                            data["displayName"] = circleName
                            data["joinKey"] = circleKey
                            ref.child("circles/\(cleanName)").setValue(data)
                        }
                        
                        var udata : [String : Any]
                        
                        udata = [:]
                        udata["id"] = id
                        udata["name"] = name
                        udata["karma"] = 50.00
                        udata["photoURL"] = "default"
                        
                        ref.child("circles/\(cleanName)/members/\(userName)").setValue(udata)
                        ref.child("users/\(id)/circles/\(cleanName)").setValue(true)
                        
                        UserUtil.getCurrentProperty(key: "phoneNumber") { number in
                            ref.child("circles/\(cleanName)/members/\(userName)/phoneNumber").setValue(number as! String)
                        }
                        
                        // let cleanName = circleName.clean()
                        PushNotification.notifyNewMember(topic: cleanName)
                        Messaging.messaging().subscribe(toTopic: "\(cleanName)")
                        
                    } else {
                        print("Unable to retrieve user property")
                    }
                    callback()
                }
            }
        }
    }
    
    // Check if the circle already exists on the database
    func exists(completionHandler: @escaping(_ exist: Bool) -> ()) {
        let ref = Database.database().reference()
        if let name = self.joinName {
            let cleanName = name.clean()
            ref.child("circles").child(cleanName).observeSingleEvent(of: .value, with: { (snapshot) in
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
            let cleanName = name.clean()
            ref.child("circles").child(cleanName).observeSingleEvent(of: .value, with: { (snapshot) in
                let entity = snapshot.value as? NSDictionary
                if let entity = entity, let joinKey = self.joinKey, let name = entity["joinName"], let password = entity["joinKey"] {
                    let name = name as! String
                    let password = password as! String
                    completionHandler(name == cleanName && password == joinKey)
                } else {
                    completionHandler(false)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
}
