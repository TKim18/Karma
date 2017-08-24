//
//  User.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/20/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

class Users : BackendlessUser {
    
    
//    let backendless = Backendless.sharedInstance()!
//    //User registration
//    func register(email: String, name: String, password: String) {
//        let user = BackendlessUser()
//        user.setProperty("email", object: email)
//        user.setProperty("name", object: name)
//        user.setProperty("password", object: password)
//        
//        backendless.userService.register(
//            user,
//            response: {
//                (registeredUser : BackendlessUser?) -> Void in
//                print("User registered \(String(describing: registeredUser?.value(forKey: "email")))")
//        },
//            error: {
//                (fault : Fault?) -> Void in
//                print("Server reported an error: \(String(describing: fault?.description))")
//        })
//    }
//    
//    //User login
//    func login(id: String, pass: String) {
//        backendless.userService.login(id, password: pass)
//    }
//    
//    //User logout
//    func logout() {
//        backendless.userService.logout({
//            (result : Any?) -> Void in
//            print("User has been logged out")
//        },
//            error: {
//                (fault : Fault?) -> Void in
//                print("Server reported an error: \(String(describing: fault?.description))")
//        })
//    }
}
