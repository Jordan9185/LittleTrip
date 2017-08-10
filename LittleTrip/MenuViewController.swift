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
import FirebaseDatabase

class MenuViewController: UIViewController {

    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userNameTextField: UITextField!
    
    var userRef: DatabaseReference?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        catchUserData()
        
        userNameTextField.delegate = self
        
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeUserPicture)))
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(true)
        
        userRef?.removeAllObservers()
        
    }
    
    @IBAction func mainPageButtonTapped(_ sender: UIButton) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainFlow") {
            
            self.slideMenuController()?.mainViewController = controller
            
            self.slideMenuController()?.closeLeft()
        }
        
    }

    @IBAction func friendListButtonTapped(_ sender: UIButton) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "FriendList") {
            
            self.slideMenuController()?.mainViewController = controller
            
            self.slideMenuController()?.closeLeft()
        }
        
    }
    
    @IBAction func SignOutActionTapped(_ sender: UIButton) {
        
        do {
            
            try Auth.auth().signOut()
            
        } catch(let error) {
            
            print(error)
            
        }
        
    }

    func catchUserData() {
        
        startLoading()
        
        let user = Auth.auth().currentUser
        
        if let userID = user?.uid {
        
            userRef = Database.database().reference().child("user").child(userID)
        
            userRef?.observe(.value, with: { (snapshot) in
                
                if  let userData = snapshot.value as? [String:Any]{
                    
                    if let userImageURL = userData["imageURL"] as? String {
                        
                        self.userImageView.sd_setImage(with: URL(string: userImageURL))
                        
                        self.userImageView.contentMode = .scaleAspectFill
                        
                        if userImageURL == defaultImageURLString {
                           
                            self.userImageView.contentMode = .center
                            
                        }
                        
                        UserDefaults.standard.set(URL(string: userImageURL), forKey: "userImageURL")

                    }
                    
                    if let userName = userData["name"] as? String {
                    
                        self.userNameTextField.text = userName
                        
                        UserDefaults.standard.set(userName, forKey: "userName")
                        
                    }
                    
                }
                
                endLoading()
            
            })
        }
        
    }
}

extension MenuViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.userNameTextField {
            
            updateUserName()
            
        }
        
    }
    
    func updateUserName() {
        
        let uid = (Auth.auth().currentUser?.uid)!
        
        let userRef = Database.database().reference().child("user").child(uid)
        
        let updateDic = [
            "name" : (self.userNameTextField.text)!
        ]
        
        userRef.updateChildValues(updateDic)
        
    }
    
}

extension MenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func changeUserPicture() {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let openCamera = UIAlertAction(title: "Open camera", style: .default) { action in
                
                imagePicker.sourceType = .camera
                
                self.present(imagePicker, animated: true, completion: nil)
                
            }
            
            actionSheet.addAction(openCamera)
            
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        {
            let openPhotoAlbum = UIAlertAction(title: "Open album", style: .default) { action in
                
                imagePicker.sourceType = .photoLibrary
                
                self.present(imagePicker, animated: true, completion: nil)
                
            }
            
            actionSheet.addAction(openPhotoAlbum)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.userImageView.image = image
            
            self.userImageView.contentMode = .scaleAspectFill
            
            updateUserImage(image)
            
        } else {
            
            print("pick image fail")
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func updateUserImage(_ image: UIImage) {
        
        let uid = (Auth.auth().currentUser?.uid)!
        
        if let imageData = UIImageJPEGRepresentation(image, 0.7) {
            
            let metaData = StorageMetadata()
            
            metaData.contentType = "image/jpeg"
            
            let imageRef = Storage.storage().reference().child("UserPic/\(uid).jpg")
            
            imageRef.putData(imageData, metadata: metaData, completion: { (metadata, error) in
                
                if let error = error {
                    
                    print("Upload Image fail: \(error)")
                    
                    return
                    
                }
                
                let imageURLString = (metadata?.downloadURL()?.absoluteString)!
                
                let userRef = Database.database().reference().child("user").child(uid)
                
                let updateDic = [
                    "imageURL" : imageURLString
                ]
                
                userRef.updateChildValues(updateDic)
                
            })
        }
        
    }
    
}
