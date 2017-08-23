//
//  HostTableViewCell.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/23.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

class HostTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
