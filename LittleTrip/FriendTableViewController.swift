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

    var userListRef: DatabaseReference?
    
    let uid = (Auth.auth().currentUser?.uid)!
    
    var friends:[User] = []
    
    let sections: [sectionType] = [.myUID, .friendList]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        catchFriendList()
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        userListRef?.removeAllObservers()
        
    }
    
    func catchFriendList() {
        
        self.userListRef = Database.database().reference().child("user")
        
        self.userListRef?.child(uid).child("friendList").observe(.value, with: { (snapshot) in
            
            self.friends = []
            
            if let friendIDs = snapshot.value as? [String] {
                
                friendIDs.map({ friendID in
                    
                    self.getFriendData(friendID)

                })

            }
            
        })
        
    }

    func getFriendData(_ friendID: String) {
        
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
        
            cell.friendNameLabel.text = "My UID: \(uid)"
            
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
        
            let headerView = UIView(frame: CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 84))
        
            let labelView = UILabel(frame: CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 84))
        
            let button = UIButton(frame: CGRect(x: self.view.frame.width - 110, y: 21, width: 100, height: 42))
            
            button.setTitle("Add Friend", for: .normal)
            
            button.backgroundColor = .black
            
            button.setTitleColor(.white, for: .normal)
            
            button.addTarget(self, action: #selector(addFriendAction), for: .touchUpInside)
            
            labelView.text = "Friend List"
        
            labelView.textAlignment = .center
        
            labelView.backgroundColor = UIColor.yellow
            
            headerView.addSubview(labelView)
            
            headerView.addSubview(button)
        
            return headerView
        
        case .friendList:
            
            return nil
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch self.sections[section] {
            
        case .myUID:
            
            return 84
            
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
    
    func addFriendAction(_ sender: UIButton) {
        
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
            
            showAlert(title: "Same as user", message: "UID is same as current user.")
            
            return
            
        }
        
        self.friends.map { (friend) in
            
            if friend.uid == friendID {
                
                showAlert(title: "User has already added", message: "\(friendID) has already added in list.")

                return
            }
            
        }
        
        self.userListRef?.child(friendID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                var friendList: [String] = []
                
                self.friends.map({ (friend) in
                    
                    friendList.append(friend.uid)
                    
                })
                
                friendList.append(friendID)
                
                self.userListRef?.child(uid).child("friendList").setValue(friendList)

                
            } else {
            
                self.showAlert(title: "user isn't exist.", message: "user isn't exist.")
            
            }
            
        })
        
    }
    
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}
