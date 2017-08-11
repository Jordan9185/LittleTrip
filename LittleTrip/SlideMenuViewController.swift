//
//  SlideMenuViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/7.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class SlideMenuViewController: SlideMenuController {
    
    override func awakeFromNib() {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainFlow") {
            self.mainViewController = controller
        }
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Left") {
            self.leftViewController = controller
        }
        
        super.awakeFromNib()
    }

}
