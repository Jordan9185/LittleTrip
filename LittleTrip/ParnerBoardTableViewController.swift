//
//  ParnerBoardTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/9.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

import FirebaseDatabase

struct Message {
    
    let poster: String
    
    let postTime: String
    
    let contentText: String
    
}

class ParnerBoardTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentSchedule: Schedule!
    
    var chatroomRef = Database.database().reference().child("scheduleChatroom")
    
    var messages: [Message] = []
    
    @IBOutlet var willSendMsgTextField: UITextField!

    @IBOutlet var tableView: UITableView!
    
    override func loadView() {
        
        super.loadView()
        
        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        currentSchedule = myTabBarViewController.schedule!
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        willSendMsgTextField.delegate = self
        
        catchChatroomMessage()
        
    }

    func catchChatroomMessage() {
        
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
                
                self.tableView.reloadData()
                
            }
            
        })
        
    }
    
    @IBAction func sendMessageActionTapped(_ sender: UIButton) {
        
        let userName = UserDefaults.standard.string(forKey: "userName")
        
        let dateFormatter = DateFormatter()
        
        let date = Date()
        
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let currentTime = dateFormatter.string(from: date)
        
        let message = (willSendMsgTextField.text)!
        
        let updateDic = [
            "poster": userName,
            "postTime": currentTime,
            "contentText": message
        ]
        
        chatroomRef.child(currentSchedule.scheduleId).child("messages").updateChildValues(["\(self.messages.count)": updateDic])
        
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
        
        cell.nameLabel.text = "\(poster) \(postTime)"
        
        cell.messageLabel.text = messages[indexPath.row].contentText

        return cell
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        if segue.identifier == "embedParnerListCollectionView" {
            
            print(segue.destination)
            
            let parnerCollectionViewController = segue.destination as! ParnerCollectionViewController
            
            parnerCollectionViewController.currentSchedule = self.currentSchedule
            
        }
        
    }

}

extension ParnerBoardTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
}
