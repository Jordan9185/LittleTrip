//
//  ScheduleMainTableViewCell.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/27.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

class ScheduleMainTableViewCell: UITableViewCell {

    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var textBackView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setBackgroundImageViewConfig()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setBackgroundImageViewConfig() {
        
        backgroundImageView.layer.cornerRadius = 10
        
    }

    
}
