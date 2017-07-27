//
//  CreateNewScheduleViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/27.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class CreateNewScheduleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var willUploadImageView: UIImageView!
    
    @IBOutlet var scheduleNameTextField: UITextField!
    
    @IBOutlet var dateTextField: UITextField!
    
    @IBOutlet var daysTextField: UITextField!
    
    let dateFormatter = DateFormatter()
    
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
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        dateTextField.text = dateFormatter.string(from: Date())

    }
    
    func doneButtonTapped() {
        
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
        
        let scheduleName = scheduleNameTextField.text ?? ""
        
        let date = dateTextField.text ?? ""
        
        let days = daysTextField.text ?? ""
        
        if scheduleName == "" { return }
        
        if date == "" { return }
        
        if days == "" { return }
        
        let ref = Database.database().reference().child("schedule")

        let key = ref.childByAutoId().key
        
        let schedule = [
            "title": scheduleName,
            "days": Int(days),
            "createdDate": date,
            "uid": Auth.auth().currentUser?.uid
        ] as [String : Any]
        
        let childUpdates = ["/\(key)": schedule]
        
        ref.updateChildValues(childUpdates)
        
        dismiss(animated: true, completion: nil)
        
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
