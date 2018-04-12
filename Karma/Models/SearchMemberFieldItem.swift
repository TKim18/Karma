//
//  SearchMemberFieldItem.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 4/11/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import Foundation
import Firebase
import SearchTextField

class SearchMemberFieldItem : SearchTextFieldItem {
    // Title = name
    // Subtitle = userName
    
    let id : String
    
    init (title: String, subtitle: String?, id: String, image : UIImage?) {
        self.id = id
        super.init(title: title, subtitle: subtitle, image: image)
    }
}
