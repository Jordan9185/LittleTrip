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
    
    var scheduleRef: DatabaseReference?
    
    @IBOutlet var schedulesTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        print("appear")
        
        getScheduleDataOnServer()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
        
        self.scheduleRef?.removeAllObservers()
        
    }
    
    func getScheduleDataOnServer() {
        
        self.scheduleRef = Database.database().reference().child("schedule")
        
        self.scheduleRef?.observe(DataEventType.value, with: { (snapshot) in

            var localSchedules: [Schedule] = []
            
            if let schedules = snapshot.value as? [String:Any] {
                
                for schedule in schedules {
                    
                    let value = schedule.value as! [String:Any]
                    
                    if Auth.auth().currentUser?.uid != value["uid"] as! String {
                        
                        continue
                        
                    }
                    
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
            
        })
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == scheduleSection.mySchedule.rawValue {
            
            return schedules.count
            
        }
        
        return 0
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleMainTableViewCell

        cell.titleLabel.text = schedules[indexPath.row].title
        
        cell.backgroundImageView.contentMode = .scaleAspectFill
        
        cell.backgroundImageView.sd_setImage(with: URL(string: schedules[indexPath.row].imageUrl))
        
        cell.tag = indexPath.row
        
        return cell
        
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        
        label.textAlignment = .center
        
        label.textColor = .brown
        
        label.text = "My Schedule"
        
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        
        headerView.backgroundColor = UIColor(red: 1, green: 235/255, blue: 205/255, alpha: 0.7)
        
        headerView.addSubview(label)
        
        return headerView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            
        case .delete :
            
            let currentScheduleID = self.schedules[indexPath.row].scheduleId
            
            let currentRef = self.scheduleRef?.child(currentScheduleID)
            
            let currentDailyRef = Database.database().reference().child("dailySchedule").child(currentScheduleID)
            
            let currentBaggageListRef = Database.database().reference().child("baggageList").child(currentScheduleID)
            
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
            
            let nextViewController = segue.destination as! DailyTabBarViewController
            
            nextViewController.schedule = schedules[cell.tag]
            
        }
        
    }
    
}
