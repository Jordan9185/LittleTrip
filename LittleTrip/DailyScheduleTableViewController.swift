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
    
    var travelTime: String
    
}

class DailyScheduleTableViewController: UITableViewController {

    var currentSchedule: Schedule!
    
    var dailySchedules: [Int: [DailySchedule]] = [:]
    
    var dailyScheduleRef: DatabaseReference?
    
    let userRef = Database.database().reference().child("user")
    
    @IBOutlet var dailySchedulesTableView: UITableView!
    

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        catchScheduleHostData()
        
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
            
            startLoading()
            
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
                            ),
                            travelTime: ""
                        )
                        
                        snapshotValuesArray.append(newDailySchedule)
                        
                    }
                    
                    self.dailySchedules.updateValue(snapshotValuesArray, forKey: index)
                    
                }
                
                self.dailySchedulesTableView.reloadData()
                
            }
            
            endLoading()
            
        }, withCancel: { (error) in
            
            print(error)
        })
    }
    
    
    func catchScheduleHostData() {
        
        userRef.child(currentSchedule.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            startLoading()
            
            if let values = snapshot.value as? [String:Any] {
                
                let name = values["name"] as? String ?? ""
                
                let pictureURL = values["imageURL"] as? String ?? ""
                
                let user = User(
                    uid: self.currentSchedule.uid,
                    name: name,
                    pictureURL: pictureURL
                )
                
                let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
                
                myTabBarViewController.scheduleHost = user
                
            }
            
            endLoading()
            
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
        
        cell.travelTimeLabel.text = ""
        
        var userLocation = CLLocationCoordinate2D(latitude: 25, longitude: 121)
        
        if indexPath.row != 0 {
            
            userLocation = (self.dailySchedules[indexPath.section]?[indexPath.row - 1].coordinate)!
            
            self.requestTravelTime(origin: userLocation, destination: (currentDailySchedule?.coordinate)!, indexPath: indexPath)
            
            cell.startTimeTextField.isHidden = false
            
            //cell.endTimeTextField.isHidden = true
            
            cell.toLabel.isHidden = false
            
            cell.headerImageView.isHidden = true
            
        } else {
            
            cell.travelTimeLabel.text = "起點"
            
            cell.headerImageView.image = #imageLiteral(resourceName: "start")
            
            cell.startTimeTextField.isHidden = true
            
            //cell.endTimeTextField.isHidden = true
            
            cell.toLabel.isHidden = true
            
            cell.headerImageView.isHidden = false
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        
        label.textAlignment = .center
        
        label.textColor = .brown
        
        label.text = "Day \(section + 1)"
        
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        
        headerView.backgroundColor = UIColor(red: 1, green: 235/255, blue: 205/255, alpha: 0.7)
        
        headerView.addSubview(label)
        
        return headerView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.dailySchedulesTableView.frame.width, height: 40))
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.dailySchedulesTableView.frame.width, height: 40))
        
        button.setTitle("Add new daily schedule for day\(section + 1)...", for: .normal)
        
        button.titleLabel?.textAlignment = .center
        
        button.setTitleColor(.brown, for: .normal)
        
        button.titleLabel?.font = UIFont(name: "AvenirNext", size: 14)
        
        button.backgroundColor =  .white
        
        button.tag = section
        
        button.addTarget(self, action: #selector(createNewDailySchedule), for: .touchUpInside)
        
        footerView.addSubview(button)
        
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 40
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let section = indexPath.section
        
        let currentDailyScheduleRef = self.dailyScheduleRef
        
        let deleteRowAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            
            if indexPath.row == 0 {
                
                self.dailySchedules[indexPath.section]?[indexPath.row] =
                    
                    DailySchedule(
                        locationName: "尚未選擇",
                        startTime: "08:00",
                        endTime: "09:00",
                        coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                        travelTime: "起點"
                        
                )
                
            } else {
                
                self.dailySchedules[indexPath.section]?.remove(at: indexPath.row)
                
            }
            
            var updateDics: [[String:Any]] = []
            
            for dailySchedule in self.dailySchedules[section]! {
                
                let updateDic: [String:Any] = [
                    "endTime": "\(dailySchedule.endTime)",
                    "latitude": "\(dailySchedule.coordinate.latitude)",
                    "locationName": "\(dailySchedule.locationName)",
                    "longitude": "\(dailySchedule.coordinate.longitude)",
                    "startTime": "\(dailySchedule.startTime)"
                ]
                
                updateDics.append(updateDic)
                
            }

            currentDailyScheduleRef?.updateChildValues(["\(section)": updateDics])
            
        }
        
        return [deleteRowAction]
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.pickLocationButtonTapped(indexPath)

    }
    
    func createNewDailySchedule(sender: UIButton) {
        
        let currentSection = sender.tag
        
        let newRow = (self.dailySchedules[currentSection]?.count)!
        
        var previousScheduleEndTime = ""
        
        if (newRow - 1) > -1 {
            
            previousScheduleEndTime = (self.dailySchedules[currentSection]?[newRow - 1].endTime)!
            
        } else {
            previousScheduleEndTime = "08:00"
        }
        
        let updateDic: [String:Any] = {
            [
                "endTime" : "08:00",
                "latitude" : "0",
                "locationName" : "尚未選擇",
                "longitude" : "0",
                "startTime" : previousScheduleEndTime
            ]
        }()
        
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

        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        myTabBarViewController.dailySchedules = self.dailySchedules
        
        self.dailyScheduleRef?.removeAllObservers()
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func requestTravelTime(origin:CLLocationCoordinate2D, destination: CLLocationCoordinate2D, indexPath:IndexPath) {
        
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
                    
                    if let rows = jsonValue?["rows"] as? [[String:Any]],
                        let elements = rows[0]["elements"] as? [[String:Any]],
                        let duration = elements[0]["duration"] as? [String:Any]
                    {
                        
                        self.dailySchedules[indexPath.section]?[indexPath.row].travelTime = (duration["text"] as? String)!
                        
                        //test
                        
                        if let totalTimeValue = duration["value"] as? Int {
                            
                            var hour = totalTimeValue / 3600
                            
                            var min = (totalTimeValue % 3600) / 60
                            
                            let dateFormatter = DateFormatter()
                            
                            dateFormatter.dateFormat = "HH:mm"
                            
                            let date = dateFormatter.date(from: (self.dailySchedules[indexPath.section]?[indexPath.row-1].endTime)!)
                            
                            let calendar = Calendar(identifier: .chinese)
                            
                            hour += calendar.component(.hour, from: date!)
                            
                            min += calendar.component(.minute, from: date!)
                            
                            if min >= 60 {
                                
                                hour += min / 60
                                
                                min = min % 60
                                
                            }
                            
                            if hour >= 24 {
                                
                                hour = hour % 24
                                
                            }
                            
                            self.dailySchedules[indexPath.section]?[indexPath.row].startTime = "\(hour):\(min)"
                        }
                        
                        //test
                        
                        DispatchQueue.main.async {
                                
                            let cell = self.dailySchedulesTableView.cellForRow(at: indexPath) as? DailyScheduleTableViewCell
                            
                            if let travelTime = duration["text"] as? String {
                            
                             cell?.travelTimeLabel.text = "預估路程約 \(travelTime)"
                                
                            }
                            
                            cell?.startTimeTextField.text = self.dailySchedules[indexPath.section]?[indexPath.row].startTime
                            
                        }
                    
                    }
                    
                }
                
            }
            
        }
        
        task.resume()
    }
    
}

