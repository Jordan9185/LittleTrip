//
//  MainFlowViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/16.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

class MainFlowViewController: UINavigationController {

    var isTripGroipMode:Bool!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        if isTripGroipMode == nil {
            
            isTripGroipMode = false
            
        }
        
    }


}
