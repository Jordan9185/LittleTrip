//
//  DailyScheduleTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/28.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GooglePlacePicker

struct DailySchedule {
    
    var locationName: String
    
    var startTime: String
    
    var endTime: String
    
    var coordinate: CLLocationCoordinate2D
    
}

enum DailyScheduleError: Error {
    
    case dailyDataOfSectionError
    
}

class DailyScheduleTableViewController: UITableViewController {

    var currentSchedule: Schedule!
    
    var dailySchedules: [Int: [DailySchedule]] = [:]
    
    var dailyScheduleRef: DatabaseReference?
    
    @IBOutlet var dailySchedulesTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        currentSchedule = myTabBarViewController.schedule!
        
        catchDailySchedules()

    }
    
    func catchDailySchedules() {
        
        self.dailyScheduleRef = Database.database().reference().child("dailySchedule").child(currentSchedule.scheduleId)
        
        self.dailyScheduleRef?.observe(.value, with: { (snapshot) in
            
            if let snapshotValues = snapshot.value as? [[[String:Any]]] {
                
                for (index , _) in snapshotValues.enumerated() {
                    
                    var snapshotValuesArray: [DailySchedule] = []
                    
                    for snapshotValues in snapshotValues[index] {
                        
                        let latitude = snapshotValues["latitude"] as! String
                        
                        let longitude = snapshotValues["longitude"] as! String
                        
                        let newDailySchedule = DailySchedule(
                            locationName: snapshotValues["locationName"] as! String,
                            startTime: snapshotValues["startTime"] as! String,
                            endTime: snapshotValues["endTime"] as! String,
                            coordinate: CLLocationCoordinate2D(
                                latitude: Double(latitude)!,
                                longitude: Double(longitude)!
                            )
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
        
        cell.locationNameButton.tag = indexPath.section * 1000 + indexPath.row
        
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
        
        let updateDic: [String:Any] = {
            [
                "endTime" : "09:00",
                "latitude" : "21.0",
                "locationName" : "尚未選擇",
                "longitude" : "125.0",
                "startTime" : "08:00"
            ]
        }()
        
        let currentSection = sender.tag
        
        let newRow = (self.dailySchedules[currentSection]?.count)!
        
        let currentDailyScheduleRef = self.dailyScheduleRef?.child("\(currentSection)").child("\(newRow)")
        
        currentDailyScheduleRef?.updateChildValues(updateDic)
        
        self.dailySchedulesTableView.reloadData()
        
    }
    
    @IBAction func pickLocationButtonTapped(_ sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag % 1000, section: sender.tag / 1000)
        
        var currentDailySchedule = self.dailySchedules[indexPath.section]?[indexPath.row]
        
        let config = GMSPlacePickerConfig(viewport: nil)
        
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: { (place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place selected")
                return
            }
            
            currentDailySchedule?.locationName = place.name

            currentDailySchedule?.coordinate = place.coordinate
            
            self.dailySchedules[indexPath.section]?[indexPath.row] = currentDailySchedule!
            
            self.syncDailySchedulesfromLocal(
                indexPath: indexPath,
                placeName: place.name ,
                placeCoordinate: place.coordinate
            )
            
            self.dailySchedulesTableView.reloadData()
            
        })
        
    }
    
    func syncDailySchedulesfromLocal(indexPath: IndexPath, placeName: String, placeCoordinate: CLLocationCoordinate2D) {
        
        let updateDic: [String:Any] = {
            [
                "endTime" : "09:00",
                "latitude" : "\(placeCoordinate.latitude)",
                "locationName" : placeName,
                "longitude" : "\(placeCoordinate.longitude)",
                "startTime" : "08:00"
            ]
        }()
        
        let currentDailyScheduleRef = self.dailyScheduleRef?.child("\(indexPath.section)").child("\(indexPath.row)")
        
        currentDailyScheduleRef?.updateChildValues(updateDic)
        
    }
    
}
