//
//  Util.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 10/29/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

//
//  UserHelper.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 10/12/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

class Util {
    //Deprecated
    static func round(_ value: Double, toNearest: Double) -> Double {
        return Darwin.round(value / toNearest) * toNearest
    }
    
    static func roundToCents(_ value: Double) -> Double {
        return Util.round(value, toNearest: 0.01)
    }
}




