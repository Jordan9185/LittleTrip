//
//  ParnerBoardTableViewCell.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/9.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

class ParnerBoardTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var messageLabel: UILabel!
    
    @IBOutlet var flexiableView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
