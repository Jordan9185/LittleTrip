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

class FriendTableViewController: UITableViewController {

    var userListRef: DatabaseReference?
    
    let uid = (Auth.auth().currentUser?.uid)!
    
    var friends:[User] = []
    
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
            
            if let friendIDs = snapshot.value as? [String] {
                
                for friendID in friendIDs {
                    
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
                
            }
            
        })
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.friends.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell

        cell.friendNameLabel.text = self.friends[indexPath.row].name
        
        cell.userImageView.sd_setImage(with: URL(string: self.friends[indexPath.row].pictureURL))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let viewWidth = self.view.frame.width
        
        let headerView = UIView(frame: CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 84))
        
        let labelView = UILabel(frame: CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 84))
        
        labelView.text = "Friend List"
        
        labelView.textAlignment = .center
        
        labelView.backgroundColor = UIColor.yellow
        
        headerView.addSubview(labelView)
        
        return headerView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 84
        
    }
    
}
