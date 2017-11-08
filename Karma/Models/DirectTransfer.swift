//
//  DirectTransfer.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 11/7/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

class DirectTransfer : NSObject {
    
    var objectId : String?
    let name : String?
    var displayName : String?
    
    override init () {
        self.name = ""
        self.displayName = ""
    }
    
    init (name: String) {
        self.name = name
        self.displayName = name
    }
    
}