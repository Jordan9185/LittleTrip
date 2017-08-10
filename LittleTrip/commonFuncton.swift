//
//  commonFuncton.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/10.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import Foundation

import SVProgressHUD

var isLoading = false

func startLoading() {
    
    if isLoading == true {
        
        return
        
    }
    
    isLoading = true
    
    SVProgressHUD.show(withStatus: "Loading")
    
    UIApplication.shared.beginIgnoringInteractionEvents()
    
}

func endLoading() {
    
    if isLoading == false {
        
        return
        
    }
    
    isLoading = false
    
    SVProgressHUD.dismiss()
    
    UIApplication.shared.endIgnoringInteractionEvents()
    
}
    
