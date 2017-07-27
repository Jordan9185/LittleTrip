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
    
    @IBOutlet var scheduleNameTextField: UITextField!
    
    @IBOutlet var dateTextField: UITextField!
    
    @IBOutlet var daysTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .date
        
        datePicker.addTarget(self, action: #selector(datePickerValueDidChanged), for: .valueChanged)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [ flexibleSpace, doneButton ]
        
        dateTextField.inputView = datePicker
        
        dateTextField.inputAccessoryView = toolbar

    }
    
    func doneButtonTapped() {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        dateTextField.text = dateFormatter.string(from: Date())
        
        dateTextField.resignFirstResponder()
        
    }
    
    func datePickerValueDidChanged(sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        dateTextField.text = dateFormatter.string(from: sender.date)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIBarButtonItem) {
        

        
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
