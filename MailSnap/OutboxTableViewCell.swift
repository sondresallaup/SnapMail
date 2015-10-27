//
//  OutboxTableViewCell.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 07/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit

class OutboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postcardImageView: UIImageView!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
