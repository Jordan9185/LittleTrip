//
//  DailyScheduleTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/28.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct DailySchedule {
    
    let locationName: String
    
    let startTime: String
    
    let endTime: String
    
    let latitude: String
    
    let longitude: String
    
}

enum DailyScheduleError: Error {
    
    case dailyDataOfSectionError
    
}

class DailyScheduleTableViewController: UITableViewController {

    var currentSchedule: Schedule!
    
    var dailySchedules: [Int: [DailySchedule]] = [:]
    
    @IBOutlet var dailySchedulesTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        currentSchedule = myTabBarViewController.schedule!
        
        catchDailySchedules()

    }
    
    func catchDailySchedules() {
        
        let dailyScheduleRef = Database.database().reference().child("dailySchedule").child(currentSchedule.scheduleId)
        
        dailyScheduleRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshotValues = snapshot.value as? [[[String:Any]]] {
                
                for (index , _) in snapshotValues.enumerated() {
                    
                    var snapshotValuesArray: [DailySchedule] = []
                    
                    for snapshotValues in snapshotValues[index] {
                        
                        let newDailySchedule = DailySchedule(
                            locationName: snapshotValues["locationName"] as! String,
                            startTime: snapshotValues["startTime"] as! String,
                            endTime: snapshotValues["endTime"] as! String,
                            latitude: snapshotValues["latitude"] as! String,
                            longitude: snapshotValues["longitude"] as! String
                        )
                        
                        snapshotValuesArray.append(newDailySchedule)
                        
                    }
                    
                    self.dailySchedules.updateValue(snapshotValuesArray, forKey: index)
                    
                }
                
                self.dailySchedulesTableView.reloadData()
                
            }
            
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return currentSchedule.days
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = self.dailySchedules[section]?.count {
            
            return count
            
        } else {
            
            return 0
        }

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dailyScheduleCell", for: indexPath) as! DailyScheduleTableViewCell

        let currentDailySchedule = self.dailySchedules[indexPath.section]?[indexPath.row]
        
        cell.startTimeLabel.text = currentDailySchedule?.startTime
        
        cell.endTimeLabel.text = currentDailySchedule?.endTime
        
        cell.locationNameButton.setTitle(currentDailySchedule?.locationName, for: .normal)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Day \(section + 1)" // 0-based
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.dailySchedulesTableView.frame.width, height: 40))
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.dailySchedulesTableView.frame.width, height: 40))
        
        button.setTitle("Add new daily schedule for day\(section + 1)...", for: .normal)
        
        button.backgroundColor = .black
        
        button.tag = section
        
        button.addTarget(self, action: #selector(createNewDailySchedule), for: .touchUpInside)
        
        footerView.addSubview(button)
        
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 40
        
    }
    
    func createNewDailySchedule(sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "CreateDailyScheduleViewController")
        
        self.navigationController?.present(nextViewController, animated: true, completion: nil)
        
    }
    
}
