//
//  DailyScheduleTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/28.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DailyScheduleTableViewController: UITableViewController {

    var currentSchedule: Schedule!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        currentSchedule = myTabBarViewController.schedule!
        
        let dailyScheduleRef = Database.database().reference().child("dailySchedule").child(currentSchedule.scheduleId)
        
        dailyScheduleRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshotValues = snapshot.value as? [[[String:Any]]] {

                for snapshotValue in snapshotValues {
                    
                    print(snapshotValue)
                }

            }

        })
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return currentSchedule.days
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dailyScheduleCell", for: indexPath) as! DailyScheduleTableViewCell

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Day \(section + 1)" // 0-based
        
    }
}
