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
        
        let ref = Database.database().reference()
        
        let scheduleRef = ref.child("schedule")

        let dailyScheduleRef = ref.child("dailySchedule")
        
        let key = scheduleRef.childByAutoId().key
        
        if let imageData = UIImageJPEGRepresentation(willUploadImageView.image!, 0.7) {
            
            let metaData = StorageMetadata()
            
            metaData.contentType = "image/jpeg"
            
            let imageRef = Storage.storage().reference().child("ScheduleImage/\(key).jpg")
            
            imageRef.putData(imageData, metadata: metaData, completion: { (metaData, error) in
                
                if let error = error {
                    
                    print("Upload Image fail: \(error)")
                    
                    return
                    
                }
                
                let schedule = [
                    "title": scheduleName,
                    "days": Int(days),
                    "createdDate": date,
                    "uid": Auth.auth().currentUser?.uid,
                    "imageURL": metaData!.downloadURL()!.absoluteString
                    ] as [String : Any]
                
                let childUpdates = ["/\(key)": schedule]
                
                scheduleRef.updateChildValues(childUpdates)
                
                let daysInt = Int(days)!
                
                for day in 0..<daysInt {
                    
                    let newDailyScheduleDic = [
                        "endTime" : "09:00",
                        "latitude" : "24.866710",
                        "locationName" : "尚未選擇",
                        "longitude" : "121.836982",
                        "startTime" : "08:00"
                        ] as [String : Any]
                    
                    dailyScheduleRef.child(key).updateChildValues(["\(day)": ["0": newDailyScheduleDic]])
                    
                }
                
            })
        }
        
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
