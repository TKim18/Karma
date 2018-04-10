//
//  PushNotif.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 4/9/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import Foundation

class PushNotification {
    static func notifyNewRequest() {
        UserUtil.getCurrentCircle() { circle in
            UserUtil.getCurrentProperty(key: "name") { name in
                let name = name as? String ?? ""
                let clean = circle.clean()
                sendNotification(title: "New Request", body: "\(name) has just requested something!", topic: clean)
            }
        }
    }
    
    static func notifyNewMember(topic: String) {
        UserUtil.getCurrentProperty(key: "name") { name in
            let name = name as? String ?? ""
            sendNotification(title: "New Member", body: "\(name) has just joined your circle!", topic: topic)
        }
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
}
