//
//  FriendTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/7.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

struct User {
    
    let uid: String
    
    let name: String
    
    let pictureURL: String
    
}

enum sectionType {
    
    case myUID
    
    case friendList
    
}

class FriendTableViewController: UITableViewController {

    var currentSchedule: Schedule?
    
    var isAddFriendMode: Bool?
    
    var scheduleHost: User?
    
    var userListRef: DatabaseReference?
    
    let uid = (Auth.auth().currentUser?.uid)!
    
    var friends:[User] = []
    
    let sections: [sectionType] = [.myUID, .friendList]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if isAddFriendMode == nil {
            
            self.isAddFriendMode = false
            
        }
        
        catchFriendList()
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        userListRef?.removeAllObservers()
        
    }
    
    func catchFriendList() {
        
        startLoading()
        
        self.userListRef = Database.database().reference().child("user")
        
        self.userListRef?.child(uid).child("friendList").observe(.value, with: { (snapshot) in
            
            self.friends = []
            
            if let friendIDs = snapshot.value as? [String] {
                
                friendIDs.map({ friendID in
                    
                    self.getFriendData(friendID)

                })
                
            }
            
            endLoading()
            
        })
        
    }

    func getFriendData(_ friendID: String) {
        
        startLoading()
        
        self.userListRef?.child(friendID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let values = snapshot.value as? [String:Any],
                let name = values["name"] as? String,
                let imageURL = values["imageURL"] as? String
            {
                
                let friend = User(
                    uid: friendID,
                    name: name,
                    pictureURL: imageURL
                )
                
                self.friends.append(friend)
                
                self.tableView.reloadData()
                
            }
            
            endLoading()
            
        })
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch self.sections[section] {
            
        case .myUID:
            
            return 1
            
        case .friendList:

            return self.friends.count
            
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell

        switch self.sections[indexPath.section] {
            
        case .myUID:
            
            if isAddFriendMode! {
                
                cell.friendNameLabel.text = "Add friend"
                
                cell.friendNameLabel.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: 40)
                
                cell.friendNameLabel.textAlignment = .center
                
                cell.friendNameLabel.font.withSize(40)
                
                cell.userImageView.isHidden = true
                
                cell.disMissButton.isHidden = false
                
                return cell
                
            }
            
            cell.friendNameLabel.text = "\(uid)"
            
            cell.friendNameLabel.textAlignment = .center
            
            cell.friendNameLabel.numberOfLines = 0
            
            cell.userImageView.isHidden = true
            
        case .friendList:
            
            cell.friendNameLabel.text = self.friends[indexPath.row].name
            
            cell.userImageView.sd_setImage(with: URL(string: self.friends[indexPath.row].pictureURL))
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch self.sections[section] {
            
        case .myUID:
            
            return nil
            
        case .friendList:
            
            return "Friend List (\(self.friends.count))"
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch self.sections[section] {
            
        case .myUID:
            
            if isAddFriendMode! {
                
                return nil
                
            }
            
            return headerViewSetting(viewFrame:self.view.frame, text:"My UID")
        
        case .friendList:
            
            return nil
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch self.sections[section] {
            
        case .myUID:
            
            if isAddFriendMode! {
                
                return 0
                
            }
            
            return 50
            
        case .friendList:
            
            return 40
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            
        case .delete:
            
            self.friends.remove(at: indexPath.row)

            var friendList: [String] = []
            
            self.friends.map({ (friend) in
                
                friendList.append(friend.uid)
                
            })
            
            self.userListRef?.child(uid).child("friendList").setValue(friendList)
            
        default:
            print("nothing happend")
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.sections[indexPath.section] {
            
        case .myUID:
            
            break
            
        case .friendList:
            
            if isAddFriendMode! {
                
                let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            
                    let newUserID = self.friends[indexPath.row].uid
                    
                    let newUserName = self.friends[indexPath.row].name
                    
                    let scheduleID = (self.currentSchedule?.scheduleId)!
                    
                    let currentParnerRef = Database.database().reference().child("scheduleParners").child(scheduleID).child("parners")
                    
                    if newUserID == self.scheduleHost?.uid {
                        
                        showAlert(title: "重複好友", message: "此好友為行程主人", viewController: self, confirmAction: nil, cancelAction: nil)
                        
                        return
                        
                    }
                    
                    startLoading()
                    
                    currentParnerRef.observeSingleEvent(of: .value, with: { (snap) in
                        
                        var parnerIDs: [String] = []
                        
                        if let values = snap.value as? [String] {
                            
                            if values.contains(newUserID) {
                                
                                endLoading()
                                
                                showAlert(title: "重複好友", message: "此好友已在旅伴清單", viewController: self, confirmAction: nil, cancelAction: nil)
                            
                                return
                            }
                            
                            parnerIDs = values

                        }
                        
                        parnerIDs.append(newUserID)
                        
                        currentParnerRef.setValue(parnerIDs)
                        
                        showAlert(title: "加入成功", message: "此好友已加入旅伴清單", viewController: self, confirmAction: nil, cancelAction: nil)
                        
                        endLoading()

                    })
    
                })
        
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
                showAlert(
                    title: "加入好友",
                    message: "確定嗎?",
                    viewController: self,
                    confirmAction: confirmAction,
                    cancelAction: cancelAction
                )
                
            }
        }
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addFriendActionTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Add Friend", message: "Enter your friend UID", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            
            textField.placeholder = "Your friend UID"
            
        })
        
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            
            guard let friendID = alertController.textFields?.first?.text else {
                return
            }
            
            self.updateFriendList(who: self.uid, friendID: friendID)
            
        })
        
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func updateFriendList(who uid:String, friendID:String) {
        
        if uid == friendID {
            
            showAlert(title: "Same as user", message: "UID is same as current user.", viewController: self, confirmAction: nil, cancelAction: nil)
            
            return
            
        }
        
        self.friends.map { (friend) in
            
            if friend.uid == friendID {
                
                showAlert(title: "User has already added", message: "\(friendID) has already added in list.", viewController: self, confirmAction: nil, cancelAction: nil)

                return
            }
            
        }
        
        startLoading()
        
        self.userListRef?.child(friendID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                var friendList: [String] = []
                
                self.friends.map({ (friend) in
                    
                    friendList.append(friend.uid)
                    
                })
                
                friendList.append(friendID)
                
                self.userListRef?.child(uid).child("friendList").setValue(friendList)

            } else {
            
                showAlert(title: "user isn't exist.", message: "user isn't exist.", viewController: self, confirmAction: nil, cancelAction: nil)
            
            }
            
            endLoading()
            
        })
        
    }

    @IBAction func openMenuTapped(_ sender: Any) {
        
        self.slideMenuController()?.openLeft()
        
    }
    
}
