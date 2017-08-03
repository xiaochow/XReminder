//
//  ReminderTableViewCell.swift
//  XReminder
//
//  Created by Xiaoxiao on 6/16/17.
//  Copyright © 2017 WangXiaoxiao. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var checkMark: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
