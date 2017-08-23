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

import FirebaseAuth

struct Message {
    
    let poster: String
    
    let postTime: String
    
    let contentText: String
    
}

class ParnerBoardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserManagerDelegate {
    
    var currentSchedule: Schedule!
    
    var chatroomRef = Database.database().reference().child("scheduleChatroom")
    
    var messages: [Message] = []
    
    var scheduleHost: User!
    
    var parnerLists: [User] = []
    
    let userManager = UserManager()

    @IBOutlet var scrollViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var willSendMsgTextView: UITextView!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        self.userManager.delegate = self
        
        self.userManager.catchParnerList(scheduleID: currentSchedule.scheduleId)
        
    }
    
    func manager(_ manager:UserManager, didGet parnerList: [User]){
        
        self.parnerLists = parnerList
        
        self.tableView.reloadData()
        
    }
    
    func manager(_ manager:UserManager, didFailWith error: UserError){
        
        print(error)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.estimatedRowHeight = 200
        
        catchChatroomMessage()
        
        setTableViewBackgroundImage()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(keyboardHidden))
        
        tap.cancelsTouchesInView = false
        
        willSendMsgTextView.delegate = self
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        willSendMsgTextView.resignFirstResponder()
    }
    
    func keyboardHidden() {
        
        self.view.endEditing(true)
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
        
        let userEmail = (Auth.auth().currentUser?.email)!
        
        let dateFormatter = DateFormatter()
        
        let date = Date()
        
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let currentTime = dateFormatter.string(from: date)
        
        let message = (willSendMsgTextView.text)!
        
        if message == "" {
            
            return
            
        }
        
        let updateDic = [
            "poster": userEmail,
            "postTime": currentTime,
            "contentText": message
        ]
        
        chatroomRef.child(currentSchedule.scheduleId).child("messages").updateChildValues(["\(self.messages.count)": updateDic])
        
        willSendMsgTextView.text = ""
        
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
        
        let ParnerCell = tableView.dequeueReusableCell(withIdentifier: "ParnerCell", for: indexPath) as! ParnerBoardTableViewCell

        let HostCell = tableView.dequeueReusableCell(withIdentifier: "HostCell", for: indexPath) as! HostTableViewCell
        
        let poster = messages[indexPath.row].poster
        
        let postTime = messages[indexPath.row].postTime
        
        let userName = UserDefaults.standard.string(forKey: "userName")
        
        let userEmail = Auth.auth().currentUser?.email!
        
        if messages[indexPath.row].poster == userEmail {
            
            HostCell.backgroundColor = UIColor.clear
            
            HostCell.messageLabel.text = messages[indexPath.row].contentText
            
            
            
            HostCell.nameLabel.text = "\(userName!) \(postTime) "
            
            return HostCell
            
        } else {
            
            ParnerCell.backgroundColor = UIColor.clear
            
            ParnerCell.messageLabel.text = messages[indexPath.row].contentText
            
            
            
            ParnerCell.nameLabel.text = "\(self.scheduleHost.name) \(postTime)"
            
            self.parnerLists.map({ (user) in
                if user.email == poster {
                    
                    ParnerCell.nameLabel.text = "\(user.name) \(postTime)"
                    
                    return
                }
            })
            
            return ParnerCell
            
        }
        
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

extension ParnerBoardTableViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        textView.text = ""
        
        textView.textColor = .black
        
        let center = NotificationCenter.default
        
        center.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: .UIKeyboardWillShow,
            object: nil
        )
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        scrollViewBottomConstraint.constant = 0
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue.size
        
        scrollViewBottomConstraint.constant = keyboardSize.height - 50
        
    }
    
}
