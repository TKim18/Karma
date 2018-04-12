//
//  UserHelper.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 10/12/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation
import Firebase
import Kingfisher

class UserUtil {
    
    //------------------------ Handling User Properties ----------------------------//
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
        if let userId = getCurrentId() {
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
    
    static func setCurrentProperty (key: String, value: String) {
        if let userId = getCurrentId() {
            UserUtil.getCurrentUserName() { userName in
                UserUtil.getCurrentCircle() { circleName in
                    let ref = Database.database().reference()
                    ref.child("users/\(userId)/\(key)").setValue(value)
                    ref.child("circles/\(circleName)/members/\(userName)/\(key)").setValue(value)
                }
            }
        }
    }
    
    static func setImageURL(photoURL : URL) {
        getCurrentCircle() { circleName in
            getCurrentUserName() { userName in
                let ref = Database.database().reference()
                let id = getCurrentId()!
                ref.child("users/\(id)").child("photoURL").setValue(photoURL.absoluteString)
                ref.child("circles/\(circleName)/members/\(userName)/photoURL").setValue(photoURL.absoluteString)
            }
        }
    }
    
    static func getImage(id: String, path: String, fromCache: Bool, completionHandler: @escaping (_ image: Image) -> ()) {
        if path == "default" {
            completionHandler(#imageLiteral(resourceName: "DefaultAvatar"))
            return
        }
        if fromCache {
            ImageCache.default.retrieveImage(forKey: id, options: nil) {
                image, cacheType in
                if let image = image {
                    completionHandler(image)
                    return
                }
            }
        }
        getImageFromServer(path: path) { image in
            completionHandler(image)
        }
    }
    
    private static func getImageFromServer(path: String, completionHandler: @escaping (_ image: Image) -> ()){
        let storageRef = Storage.storage().reference()
        storageRef.child(path).getData(maxSize: INT64_MAX) {(data, error) in
            if let error = error {
                print(error.localizedDescription)
                completionHandler(#imageLiteral(resourceName: "DefaultAvatar"))
            }
            DispatchQueue.main.async {
                let serverImage = UIImage.init(data: data!)!
                self.saveImageToCache(image: serverImage)
                completionHandler(serverImage)
            }
        }
    }
    
    static func saveImageToCache(image: UIImage) {
        let id = UserUtil.getCurrentId()!
        ImageCache.default.removeImage(forKey: id)
        ImageCache.default.store(image, forKey: id)
        print("User image has been saved to cache")
    }
    
    //------------------------ Handling Transaction ----------------------------//
    
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
}
