//
//  SignInViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/25.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var mainContentStackView: UIStackView!
    
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

        scrollView.contentInset = UIEdgeInsets.zero
    
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }

}
