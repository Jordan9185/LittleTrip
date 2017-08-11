//
//  ScheduleMainTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/27.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

enum scheduleSection: Int {
    
    case mySchedule = 0
    
    case iAmJoining
    
}

struct Schedule {
    
    let title: String
    
    let days: Int
    
    let createdDate: String
    
    let uid: String
    
    let imageUrl: String
    
    let scheduleId: String
    
}

class ScheduleMainTableViewController: UITableViewController {

    var schedules: [Schedule] = []
    
    var scheduleHadJoineds: [Schedule] = []
    
    var rootRef = Database.database().reference()
    
    var scheduleRef: DatabaseReference?
    
    var scheduleHadJoinedRef: DatabaseReference?
    
    let mainViewSections: [scheduleSection] = [ .mySchedule, .iAmJoining]
    
    @IBOutlet var schedulesTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        getScheduleDataOnServer()
        
        getScheduleHadJoinedOnServer()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
        
        self.scheduleRef?.removeAllObservers()
        
        self.scheduleHadJoinedRef?.removeAllObservers()
        
    }
    
    func getScheduleDataOnServer() {
        
        self.scheduleRef = rootRef.child("schedule")
        
        let uid = (Auth.auth().currentUser?.uid)!
        
        let ref = self.scheduleRef?.queryOrdered(byChild: "uid").queryEqual(toValue: uid)
        
        startLoading()
        
        ref?.observe(.value, with: { (snapshot) in
            
            var localSchedules: [Schedule] = []
            
            if let schedules = snapshot.value as? [String:Any] {
                
                for schedule in schedules {
                    
                    let value = schedule.value as! [String:Any]
                    
                    localSchedules.append(
                        
                        Schedule(
                            title: value["title"] as! String,
                            days: value["days"] as! Int,
                            createdDate: value["createdDate"] as! String,
                            uid: value["uid"] as! String,
                            imageUrl: value["imageURL"] as! String,
                            scheduleId: schedule.key
                        )
                        
                    )
                    
                }
                
                self.schedules = localSchedules
                
                self.schedulesTableView.reloadData()
                
            }
            
            endLoading()
            
        })
 
        
    }
    
    func getScheduleHadJoinedOnServer() {
        
        startLoading()
        
        let uid = (Auth.auth().currentUser?.uid)!
        
        self.scheduleHadJoinedRef = rootRef.child("scheduleHadJoined").child(uid).child("schedules")
        
        self.scheduleHadJoinedRef?.observe(.value, with: { (snapshot) in
            
            self.scheduleHadJoineds = []
            
            if let values = snapshot.value as? [String] {
                
                values.map({ (value) in
                    
                    self.getSingleScheduleDataOnServer(scheduleID: value)
                    
                })
                
            }
            
            endLoading()
            
        })
        
    }
    
    func getSingleScheduleDataOnServer(scheduleID: String) {
        
        startLoading()
        
        var schedule: Schedule!
        
        self.scheduleRef?.child(scheduleID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let scheduleData = snapshot.value as? [String:Any] {
                
                guard
                    let title = scheduleData["title"] as? String,
                    let days = scheduleData["days"] as? Int,
                    let createdDate = scheduleData["createdDate"] as? String,
                    let uid = scheduleData["uid"] as? String,
                    let imageURL = scheduleData["imageURL"] as? String
                    else {
                        return
                }

                schedule = Schedule(title: title, days: days, createdDate: createdDate, uid: uid, imageUrl: imageURL, scheduleId: scheduleID)
                
                self.scheduleHadJoineds.append(schedule)
                
                self.tableView.reloadData()
                
            }
            
            endLoading()
        })
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 2
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch mainViewSections[section] {
            
        case .mySchedule:
            
                return schedules.count
            
        case .iAmJoining:
            
                return scheduleHadJoineds.count
            
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleMainTableViewCell
        
        switch mainViewSections[indexPath.section] {
            
        case .mySchedule:

            cell.titleLabel.text = schedules[indexPath.row].title
        
            cell.backgroundImageView.contentMode = .scaleAspectFill
        
            cell.backgroundImageView.sd_setImage(with: URL(string: schedules[indexPath.row].imageUrl))
        
            cell.tag = indexPath.section * 1000 + indexPath.row
        
            return cell
        
        case .iAmJoining:
            
            if self.scheduleHadJoineds.count == 0 {
                
                return cell
                
            }
            
            cell.titleLabel.text = scheduleHadJoineds[indexPath.row].title
            
            cell.backgroundImageView.contentMode = .scaleAspectFill
            
            cell.backgroundImageView.sd_setImage(with: URL(string: scheduleHadJoineds[indexPath.row].imageUrl))
            
            cell.tag = indexPath.section * 1000 + indexPath.row
            
            return cell
            
        }
        
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        
        headerView.backgroundColor = UIColor(red: 214/255, green: 234/255, blue: 248/255, alpha: 0.3)
        
        label.font = UIFont(name: "TrebuchetMS-Bold", size: 15)
        
        label.textAlignment = .center
        
        label.textColor = UIColor(red: 4/255, green: 107/255, blue: 149/255, alpha: 0.7)
        
        switch mainViewSections[section] {
            
        case .mySchedule:
        
            label.text = "My Schedule"
        
            headerView.addSubview(label)
        
            return headerView
            
        case .iAmJoining:
            
            label.text = "I am joining"
            
            headerView.addSubview(label)
            
            return headerView
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            
        case .delete :
            
            switch mainViewSections[indexPath.section] {
                
            case .mySchedule:
                
                let currentScheduleID = self.schedules[indexPath.row].scheduleId
                
                let currentRef = self.scheduleRef?.child(currentScheduleID)
                
                let currentDailyRef = rootRef.child("dailySchedule").child(currentScheduleID)
                
                let currentBaggageListRef = rootRef.child("baggageList").child(currentScheduleID)
                
                let imageRef = Storage.storage().reference().child("ScheduleImage/\(currentScheduleID).jpg")
                
                currentRef?.removeValue()
                
                currentDailyRef.removeValue()
                
                currentBaggageListRef.removeValue()
                
                self.schedules.remove(at: indexPath.row)
                
                // Delete the file
                imageRef.delete { error in
                    
                    if let error = error {
                        
                        print("Delete ScheduleImage/\(currentScheduleID).jpg is failed.")
                        
                    } else {
                        
                        print("Delete ScheduleImage/\(currentScheduleID).jpg is successful.")
                        
                    }
                    
                }
                
                self.tableView.reloadData()

            case .iAmJoining:
                
                let uid = (Auth.auth().currentUser?.uid)!
                
                self.scheduleHadJoineds.remove(at: indexPath.row)
                
                var localSchedules: [String] = []
                
                self.scheduleHadJoineds.map({ (schedule) in
                    
                    localSchedules.append(schedule.scheduleId)
                    
                })
                
                self.scheduleHadJoinedRef?.setValue(localSchedules)
                
            }
            
            
        default :
            
            print("unknow style")
            
        }
    }
        
    @IBAction func openMenuAction(_ sender: Any) {
        
        self.slideMenuController()?.openLeft()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToDailyTabBarController" {
            
            let cell = sender as! ScheduleMainTableViewCell
            
            let section = cell.tag / 1000
            
            let row = cell.tag % 1000
            
            let nextViewController = segue.destination as! DailyTabBarViewController
            
            switch mainViewSections[section] {
                
            case .mySchedule:
                
                nextViewController.schedule = schedules[row]
                
            case .iAmJoining:
                
                nextViewController.schedule = scheduleHadJoineds[row]
                
            }

            
        }
        
    }
    
}
