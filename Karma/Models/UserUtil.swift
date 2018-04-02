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
    
    static func getCurrentUser() -> User {
        return Auth.auth().currentUser!
    }
    
    static func getCurrentId() -> String? {
        return getCurrentUser().uid
    }
    
    static func getCurrentImageURL(completionHandler: @escaping (_ url: URL) -> ()) {
        getCurrentProperty(key: "photoURL") { path in
            let val = path as? String ?? "default"
            completionHandler(URL(string: val)!)
        }
    }
    
    static func getCurrentEmail() -> String? {
        return getCurrentUser().email
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
    
    static func transactPointsWithSnapshot(snapshot: DataSnapshot) {
        if let order = snapshot.value as? [String: Any] {
            if let points = order["points"] as? Double, let requestId = order["userId"], let requestName = order["userName"], let acceptId = order["acceptId"], let acceptName = order["acceptUserName"] {
                transactPoints(points: points, requestId: requestId as! String, requestName: requestName as! String, acceptId: acceptId as! String, acceptName: acceptName as! String)
            }
        }
    }
    
    static func transactPoints(points: Double, requestId: String, requestName: String, acceptId: String, acceptName: String) {
        
        UserUtil.getCurrentCircle() { circleName in
            let ref = Database.database().reference()
            changePoints(ref: ref.child("users/\(requestId)/karma"), op: "sub", points: points)
            changePoints(ref: ref.child("users/\(acceptId)/karma"), op: "add", points: points)
            changePoints(ref: ref.child("circles/\(circleName)/members/\(requestName)/karma"), op: "sub", points: points)
            changePoints(ref: ref.child("circles/\(circleName)/members/\(acceptName)/karma"), op: "add", points: points)
        }
    }

    static func changePoints(ref: DatabaseReference, op: String, points: Double) {
        ref.runTransactionBlock({(currentData: MutableData) -> TransactionResult in
            if var karma = currentData.value as? Double {
                (op == "add") ? (karma += points) : (karma -= points)
                currentData.value = karma
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        })
    }
 
    static func getNumAccepts(completionHandler: @escaping (_ number: Any?) -> ()) {
        getCurrentUserName() { userName in
            getCurrentCircle() { circleName in
                let ref = Database.database().reference()
                ref.child("acceptedOrders/request/\(circleName)/\(userName)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let entity = snapshot.value as? NSDictionary {
                        completionHandler(entity.count)
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    static func setImageURL(photoURL : URL) {
        let ref = Database.database().reference()
        let id = getCurrentId()!
        ref.child("users/\(id)/photoURL").setValue(photoURL.absoluteString)
    }
}
