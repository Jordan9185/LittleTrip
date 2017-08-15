//
//  ParnerCollectionViewCell.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/9.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

class ParnerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var parnerPicImageView: UIImageView!
    
    @IBOutlet var userLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setCellConfig()
        
    }
    
    func setCellConfig() {
        
        parnerPicImageView.layer.cornerRadius = parnerPicImageView.frame.width/2
        
    }
    
}
