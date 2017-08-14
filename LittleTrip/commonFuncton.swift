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

func headerViewSetting(viewFrame:CGRect, text:String) -> UIView {
    
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: viewFrame.width, height: 40))
    
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: viewFrame.width / 2, height: 30))
    
    let contentView = UIView(frame: CGRect(x: 0, y: 0, width: viewFrame.width / 2, height: 30))
    
    contentView.backgroundColor = UIColor(red: 214/255, green: 234/255, blue: 248/255, alpha: 0.8)
    
    contentView.layer.cornerRadius = 15
    
    contentView.center = CGPoint(x: headerView.frame.width/2, y: headerView.frame.height/2 + 5)
    
    label.textAlignment = .center
    
    label.textColor = UIColor(red: 4/255, green: 107/255, blue: 149/255, alpha: 0.7)
    
    label.text = text
    
    label.font = UIFont(name: "TrebuchetMS-Bold", size: 15)
    
    contentView.addSubview(label)
    
    headerView.addSubview(contentView)
    
    return headerView
    
}
