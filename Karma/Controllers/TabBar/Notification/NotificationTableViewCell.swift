//
//  RespondRequestTableViewCell.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/26/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        notificationLabel.font = UIFont.boldSystemFont(ofSize: 11.0)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var personalMessage: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!

}
