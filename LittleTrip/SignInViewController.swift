//
//  SignInViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/25.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var signInButton: UIButton!

    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        signInButton.layer.cornerRadius = 5
        
        emailTextField.delegate = self
        
        passwordTextField.delegate = self
        
        addObserverForKeyboardEvent()
        
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        let email = emailTextField.text ?? ""
        
        if email == "" {
            
            showAlert(title: "Empty", message: "Email is empty.", viewController: self, confirmAction: nil, cancelAction: nil)
            
            return
            
        }
        
        let password = passwordTextField.text ?? ""
        
        if password == "" {
            
            showAlert(title: "Empty", message: "Password is empty.", viewController: self, confirmAction: nil, cancelAction: nil)
            
            return
            
        }
        
        startLoading(status: "Logging")
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                
                endLoading()
                
                showAlert(title: "Login failure", message: "\(error.localizedDescription)", viewController: self, confirmAction: nil, cancelAction: nil)
                
                return
                
            }
            
            print("\(user) is sign in .")
            
            endLoading()
            
        }
        
    }
    
    func addObserverForKeyboardEvent() {
        
        let center = NotificationCenter.default
        
        center.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: .UIKeyboardWillShow,
            object: nil
        )
        
        center.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: .UIKeyboardWillHide,
            object: nil
        )
        
    }
    
    func keyboardWillShow(notification: NSNotification) {

        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey)! as AnyObject).cgRectValue.size
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        
        scrollView.contentInset = contentInsets
        
    }
    
    func keyboardWillHide(notification: NSNotification) {

        scrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }

}
