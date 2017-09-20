//
//  CircleTableViewCell.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 8/24/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class CircleTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //UI Elements
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var circleImage: UIImageView!

}
