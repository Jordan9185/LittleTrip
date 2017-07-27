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

enum scheduleSection: Int {
    
    case mySchedule = 0
    
    case iAmJoining
    
}

struct Schedule {
    
    let title: String
    
    let days: Int
    
    let createdDate: String
    
}

class ScheduleMainTableViewController: UITableViewController {

    var schedules: [Schedule] = []
    
    var testImage: UIImage!
    
    @IBOutlet var schedulesTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getScheduleDataOnServer()

    }

    func getScheduleDataOnServer() {
    
        var scheduleRef: DatabaseReference!
        
        scheduleRef = Database.database().reference().child("schedule")
        
        scheduleRef.observe(DataEventType.value, with: { (snapshot) in
            
            if let schedules = snapshot.value as? [[String:Any]] {
                
                let storage = Storage.storage()
                
                let downloadRef = storage.reference(withPath: "ScheduleImage/father-656734_1920.jpg")
                
                downloadRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                    
                    if let error = error {
                        
                        return
                        
                    }
                    
                    self.testImage = UIImage(data: data!)

                for schedule in schedules {
                    
                    self.schedules.append(
                        
                        Schedule(
                            title: schedule["title"] as! String,
                            days: schedule["days"] as! Int,
                            createdDate: schedule["createdDate"] as! String
                        )
                        
                    )
                    
                }
                
                self.schedulesTableView.reloadData()
                
    
                }
                
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
        
        cell.backgroundImageView.image = self.testImage
        
        return cell
        
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            
        case scheduleSection.mySchedule.rawValue : return "My schedule"
            
        case scheduleSection.iAmJoining.rawValue : return "I am joining"
        
        default: return ""
            
        }
        
    }
    
}
