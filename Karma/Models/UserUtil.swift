//
//  UserHelper.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 10/12/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation
import Firebase

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
        guard let order = snapshot.value as? [String: Any], let info = order["info"] as? [String: Any], let accUser = order["acceptUser"] as? [String: Any], let reqUser = order["requestUser"] as? [String: Any] else { return }
        if let points = info["points"] as? Double, let requestId = reqUser["id"], let requestName = reqUser["userName"], let acceptId = accUser["id"], let acceptName = accUser["userName"] {
            transactPoints(points: points, requestId: requestId as! String, requestName: requestName as! String, acceptId: acceptId as! String, acceptName: acceptName as! String)
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
        ref.child("users/\(id)").child("photoURL").setValue(photoURL.absoluteString)
    }
    
    static func sendNotification(title: String, body: String, topic: String) {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AIzaSyDEZEjjyOQChi5XW2vxJhd9gnBWlg-dUrM", forHTTPHeaderField: "Authorization")
        
        do {
            let dic : [String : Any] = [
                "condition":"'\(topic)' in topics",
                "notification" : [
                    "body" : body,
                    "title" : title
                ]
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions())
        } catch {
            print("Caught an error: \(error)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
    
    static func notifyNewRequest() {
        getCurrentCircle() { circle in
            getCurrentProperty(key: "name") { name in
                let name = name as? String ?? ""
                let clean = circle.clean()
                sendNotification(title: "New Request", body: "\(name) has just requested something!", topic: clean)
            }
        }
    }
}
