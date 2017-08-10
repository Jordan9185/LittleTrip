//
//  commonFuncton.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/10.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import Foundation

import SVProgressHUD


func startLoading() {
    
    SVProgressHUD.show()
    
    UIApplication.shared.beginIgnoringInteractionEvents()
    
}

func endLoading() {
    
    SVProgressHUD.dismiss()
    
    UIApplication.shared.endIgnoringInteractionEvents()
    
}
    
