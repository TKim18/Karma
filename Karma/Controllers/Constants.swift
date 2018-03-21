//
//  Constants.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 3/20/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

struct Constants {
    
    struct User {
        static let wesleyan = "@wesleyan.edu"
        static let university = "Wesleyan University"
        static let initialPoints = 50 as NSNumber
        static let invalidLogin = "Please enter a valid email and password"
        static let invalidPassword = "Please verify that your passwords match"
        
        struct Fields {
            static let circles = "circles"
            static let name = "name"
            static let userName = "userName"
            static let home = "home"
            static let points = "karma"
        }
    }
    
    struct Order {
        struct Fields {
            static let title = "title"
            static let description = "description"
            static let time = "requestedTime"
            static let location = "destination"
            static let category = "category"
        }
    }
    
    struct Segue {
        static let ToRegister = "LoginToRegister"
        static let ToNoCircle = "LoginNoCircle"
        static let LoginToMain = "LoginToTab"
        static let RegisterToMain = "RegisterToCircle"
    }
}

