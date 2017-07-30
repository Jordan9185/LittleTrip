//
//  DailyScheduleTableViewCell.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/28.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

class DailyScheduleTableViewCell: UITableViewCell {

    @IBOutlet var startTimeLabel: UILabel!
    
    @IBOutlet var endTimeLabel: UILabel!
    
    @IBOutlet var locationNameButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
