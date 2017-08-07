//
//  MenuViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/7.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import FirebaseStorage
import FirebaseAuth

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print(SlideMenuOptions.leftViewWidth)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignOutActionTapped(_ sender: UIButton) {
        
        do {
            
            try Auth.auth().signOut()
            
        } catch(let error) {
            
            print(error)
            
        }
        
    }

}
