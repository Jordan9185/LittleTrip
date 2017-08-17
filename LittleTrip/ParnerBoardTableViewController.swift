//
//  ParnerBoardTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/9.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

import FirebaseDatabase

import SwifterSwift

struct Message {
    
    let poster: String
    
    let postTime: String
    
    let contentText: String
    
}

class ParnerBoardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentSchedule: Schedule!
    
    var chatroomRef = Database.database().reference().child("scheduleChatroom")
    
    var messages: [Message] = []
    
    var scheduleHost: User!
    
    @IBOutlet var willSendMsgTextField: UITextField!

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    override func loadView() {
        
        super.loadView()
        
        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        currentSchedule = myTabBarViewController.schedule!
        
        scheduleHost = myTabBarViewController.scheduleHost
        
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let childCollectionViewController = storyBoard.instantiateViewController(withIdentifier: "ParnerCollectionViewController") as! ParnerCollectionViewController
        
        childCollectionViewController.scheduleHost = scheduleHost
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        willSendMsgTextField.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.estimatedRowHeight = 200
        
        catchChatroomMessage()
        
        setTableViewBackgroundImage()
        
    }

    func catchChatroomMessage() {
        
        startLoading(status: "Loading")
        
        chatroomRef.child(currentSchedule.scheduleId).child("messages").observe(.value, with: { (snapshot) in
            
            if let values = snapshot.value as? [[String:String]] {
                
                self.messages = []
                
                values.map({ (value) in

                    let poster = value["poster"]!
                    
                    let postTime = value["postTime"]!
                    
                    let contentText = value["contentText"]!
                    
                    let message = Message(
                        poster: poster,
                        postTime: postTime,
                        contentText: contentText
                    )
                    
                    self.messages.append(message)
                    
                })
                
                self.tableView.reloadData({

                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    
                })
                
                endLoading()
                
            }
            
        })
        
    }
    
    func setTableViewBackgroundImage() {
        
        let imageView = UIImageView(frame: tableView.frame)
        
        imageView.sd_setImage(with: URL(string: currentSchedule.imageUrl)!)
        
        imageView.clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.frame.size = self.view.frame.size
        
        imageView.addSubview(blurView)
        
        tableView.backgroundView = imageView
        
    }
    
    @IBAction func sendMessageActionTapped(_ sender: UIButton) {
        
        let userName = UserDefaults.standard.string(forKey: "userName")
        
        let dateFormatter = DateFormatter()
        
        let date = Date()
        
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let currentTime = dateFormatter.string(from: date)
        
        let message = (willSendMsgTextField.text)!
        
        if message == "" {
            
            return
            
        }
        
        let updateDic = [
            "poster": userName,
            "postTime": currentTime,
            "contentText": message
        ]
        
        chatroomRef.child(currentSchedule.scheduleId).child("messages").updateChildValues(["\(self.messages.count)": updateDic])
        
        willSendMsgTextField.text = ""
        
        tableView.reloadData()

    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.messages.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParnerCell", for: indexPath) as! ParnerBoardTableViewCell

        let poster = messages[indexPath.row].poster
        
        let postTime = messages[indexPath.row].postTime
        
        let userName = UserDefaults.standard.string(forKey: "userName")
        
        cell.messageLabel.text = messages[indexPath.row].contentText
        
        cell.backgroundColor = UIColor.clear
        
        if messages[indexPath.row].poster == userName {
            
            cell.nameLabel.text = "\(postTime) \(poster) "
            
            cell.nameLabel.textAlignment = .right
            
            cell.messageLabel.textAlignment = .right
            
            cell.flexiableView.isHidden = false
            
        } else {
            
            cell.nameLabel.text = "\(poster) \(postTime)"
            
            cell.nameLabel.textAlignment = .left
            
            cell.messageLabel.textAlignment = .left
            
            cell.flexiableView.isHidden = true
            
        }

        return cell
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "embedParnerListCollectionView" {
            
            let parnerCollectionViewController = segue.destination as! ParnerCollectionViewController
            
            parnerCollectionViewController.currentSchedule = self.currentSchedule
            
            parnerCollectionViewController.scheduleHost = self.scheduleHost
            
        }
        
        if segue.identifier == "fromParnerBoard" {
            
            let friendTableViewController = segue.destination as! FriendTableViewController
            
            friendTableViewController.isAddFriendMode = true
            
            friendTableViewController.currentSchedule = self.currentSchedule
            
            friendTableViewController.scheduleHost = scheduleHost
        }
        
    }

}

extension ParnerBoardTableViewController: UITextFieldDelegate {
    
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
        
        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue.size
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - 43, right: 0)
        
        scrollView.contentInset = contentInsets
        
    }
    
}
