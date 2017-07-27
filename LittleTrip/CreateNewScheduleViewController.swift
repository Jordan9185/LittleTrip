//
//  CreateNewScheduleViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/27.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

class CreateNewScheduleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var willUploadImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func pickImageButtomTapped(_ sender: UIButton) {
        
        let imagePicker = UIImagePickerController()
    
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.willUploadImageView.image = image
            
        } else {
            
            print("Catch photo error.")
            
        }
        
        self.willUploadImageView.contentMode = .scaleAspectFill
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
