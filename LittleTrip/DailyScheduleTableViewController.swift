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

class DailyScheduleTableViewController: UITableViewController {

    var currentSchedule: Schedule!
    
    var dailySchedules: [Int: [DailySchedule]] = [:]
    
    var dailyScheduleRef: DatabaseReference?
    
    @IBOutlet var dailySchedulesTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        catchDailySchedules()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        currentSchedule = myTabBarViewController.schedule!

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
            
        }, withCancel: { (error) in
            
            print(error)
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
        
        cell.startTimeTextField.text = currentDailySchedule?.startTime
        
        cell.endTimeTextField.text = currentDailySchedule?.endTime
        
        cell.locationNameLabel.text = currentDailySchedule?.locationName
        
        cell.startTimeTextField.tag = indexPath.section * 1000 + indexPath.row
        
        cell.endTimeTextField.tag = indexPath.section * 1000 + indexPath.row
        
        cell.dailyScheduleRef = self.dailyScheduleRef
        
        let userLocation = CLLocationCoordinate2D(latitude: 25, longitude: 121)
        
        self.requestTravelTime(origin: userLocation, destination: (currentDailySchedule?.coordinate)!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        myTabBarViewController.dailySchedules = self.dailySchedules
        
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let currentDailyScheduleRef = self.dailyScheduleRef?.child("\(indexPath.section)").child("\(indexPath.row)")
        
        let deleteRowAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            currentDailyScheduleRef?.removeValue()
            
        }
        
        return [deleteRowAction]
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.pickLocationButtonTapped(indexPath)

    }
    
    func createNewDailySchedule(sender: UIButton) {
        
        let updateDic: [String:Any] = {
            [
                "endTime" : "09:00",
                "latitude" : "0",
                "locationName" : "尚未選擇",
                "longitude" : "0",
                "startTime" : "08:00"
            ]
        }()
        
        let currentSection = sender.tag
        
        let newRow = (self.dailySchedules[currentSection]?.count)!
        
        let currentDailyScheduleRef = self.dailyScheduleRef?.child("\(currentSection)").child("\(newRow)")
        
        currentDailyScheduleRef?.updateChildValues(updateDic)
        
        self.dailySchedulesTableView.reloadData()
        
    }
    
    func pickLocationButtonTapped(_ indexPath: IndexPath) {
        
        let indexPath = indexPath
        
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
                "latitude" : "\(placeCoordinate.latitude)",
                "locationName" : placeName,
                "longitude" : "\(placeCoordinate.longitude)"
            ]
        }()
        
        let currentDailyScheduleRef = self.dailyScheduleRef?.child("\(indexPath.section)").child("\(indexPath.row)")
        
        currentDailyScheduleRef?.updateChildValues(updateDic)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(true)
        
        self.dailyScheduleRef?.removeAllObservers()
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func requestTravelTime(origin:CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        let originFormat = "\(origin.latitude),\(origin.longitude)"
        
        let destinationFormat = "\(destination.latitude),\(destination.longitude)"

        let url = URL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=\(originFormat)&destinations=\(destinationFormat)&key=\(googleProjectApiKey)")
        
        let urlRequest = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                
                return
                
            }
            
            do {
                
                if let jsonValue = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any] {
                    
                    if let rows = jsonValue?["rows"] as? [[String:Any]] {
                    
                        if let elements = rows[0]["elements"] as? [[String:Any]] {
                            
                            if let duration = elements[0]["duration"] as? [String:Any] {
                                print(duration)
                            }
                        }
                        
                    }
                    
                }
                
            } catch(let error) {
                
                print(error)
                
            }
        }
        
        task.resume()
    }
    
}

