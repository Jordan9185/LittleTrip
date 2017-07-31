//
//  ScheduleMainTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/27.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
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
    
    @IBOutlet var schedulesTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getScheduleDataOnServer()

    }

    func getScheduleDataOnServer() {
    
        var scheduleRef: DatabaseReference!
        

        
        scheduleRef = Database.database().reference().child("schedule")
        
        scheduleRef.observe(DataEventType.value, with: { (snapshot) in

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
            
        })
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 2
        
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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            
        case scheduleSection.mySchedule.rawValue : return "My schedule"
            
        case scheduleSection.iAmJoining.rawValue : return "I am joining"
        
        default: return ""
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToDailyTabBarController" {
            
            let cell = sender as! ScheduleMainTableViewCell
            
            let nextViewController = segue.destination as! DailyTabBarViewController
            
            nextViewController.schedule = schedules[cell.tag]
            
        }
        
    }
    
}
