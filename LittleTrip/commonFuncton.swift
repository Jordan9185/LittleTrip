//
//  commonFuncton.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/10.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

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

func showAlert(title: String, message: String, viewController: UIViewController, confirmAction: UIAlertAction?, cancelAction: UIAlertAction?) {

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    if let confirmAction = confirmAction {
            
        alertController.addAction(confirmAction)
        
    } else {
        
        let justOKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(justOKAction)
        
    }
    
    if let cancelAction = cancelAction {
        
        alertController.addAction(cancelAction)
        
    }
    
    viewController.present(alertController, animated: true, completion: nil)
    
}

