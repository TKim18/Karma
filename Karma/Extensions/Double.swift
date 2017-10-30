//
//  Double.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 10/29/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
