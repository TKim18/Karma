//
//  String.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 4/7/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import Foundation

extension String {
    func clean() -> String {
        let numSet = "01234567890."
        let upperSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lowerSet = "abcdefghijklmnopqrstuvwxyz"
        let puncSet = "._-~%"
        let cleanSet = numSet + upperSet + lowerSet + puncSet
        let noWhiteOrUpper = self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return String(noWhiteOrUpper.filter { cleanSet.contains($0) })
    }
}

