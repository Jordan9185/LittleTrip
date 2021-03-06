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
    
    @IBOutlet var scrollView: UIScrollView!
    
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
        
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 4/255, green: 107/255, blue: 149/255, alpha: 1)
        
        scheduleNameTextField.delegate = self
        
        dateTextField.delegate = self
        
        daysTextField.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(keyboardHidden))
        
        tap.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tap)

    }
    
    func keyboardHidden() {

        self.view.endEditing(true)
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
        
        if scheduleName == "" {
            
            showAlert(title: "Not correct format", message: "Schedule name is empty.", viewController: self, confirmAction: nil, cancelAction: nil)
            
            return
            
        }
        
        if date == "" { return }
        
        guard let days = Int(daysTextField.text!) as? Int else {
            
            showAlert(title: "Not correct format", message: "Days must be a number.", viewController: self, confirmAction: nil, cancelAction: nil)
            
            return
        }
        
        if days < 1 {
            
            showAlert(title: "Value incorrect", message: "At least one day.", viewController: self, confirmAction: nil, cancelAction: nil)

            return
        }
        
        startLoading(status: "Upload data, please wait a moment.")
        
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
                    "days": days,
                    "createdDate": date,
                    "uid": Auth.auth().currentUser?.uid,
                    "imageURL": metaData!.downloadURL()!.absoluteString
                    ] as [String : Any]
                
                let childUpdates = ["/\(key)": schedule]
                
                scheduleRef.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                    
                    for day in 0..<days {
                        
                        let newDailyScheduleDic = [
                            "endTime" : "09:00",
                            "latitude" : "0",
                            "locationName" : "尚未選擇",
                            "longitude" : "0",
                            "startTime" : "08:00"
                            ] as [String : Any]
                        
                        if day == days - 1 {
                            
                            dailyScheduleRef.child(key).updateChildValues(["\(day)": ["0": newDailyScheduleDic]] , withCompletionBlock: { (error, ref) in
                                
                                self.dismiss(animated: true, completion: nil)
                                
                                endLoading()
                                
                            })
                            
                        } else {
                            dailyScheduleRef.child(key).updateChildValues(["\(day)": ["0": newDailyScheduleDic]])
                        }
                        
                    }
                    
                })
                

            })
            
        }

    }
    
    @IBAction func pickImageButtomTapped(_ sender: UIButton) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self

        openCameraOrImageLibrary(imagePicker: imagePicker, viewController: self)
 
        
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

extension CreateNewScheduleViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    
        let center = NotificationCenter.default
        
        center.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: .UIKeyboardWillShow,
            object: nil
        )

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        scrollView.contentInset = UIEdgeInsets.zero
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey)! as AnyObject).cgRectValue.size
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        
        scrollView.contentInset = contentInsets
        
    }
    
}

extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKeyPath: "statusBar") as? UIView
    }
    
}
