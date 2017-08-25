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

enum scheduleSection {
    
    case mySchedule
    
    case iAmJoining
    
}

class ScheduleMainTableViewController: UITableViewController {

    var schedules: [Schedule] = []
    
    var scheduleHadJoineds: [Schedule] = []
    
    var mainViewSections: [scheduleSection] = []
    
    var isTripGroupMode: Bool!
    
    var refreshController = UIRefreshControl()
    
    @IBOutlet var emptyNotice: UILabel!
    
    @IBOutlet var addBarButton: UIBarButtonItem!
    
    @IBOutlet var schedulesTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        let nav = self.navigationController as! MainFlowViewController
        
        isTripGroupMode = nav.isTripGroipMode
        
        ScheduleManager.shared.delegate = self
        
        startLoading(status: "Loading")
        
        if isTripGroupMode {
            
            ScheduleManager.shared.getScheduleHadJoinedOnServer()
            
            mainViewSections = [.iAmJoining]
        
            addBarButton.isEnabled = false
            
            addBarButton.image = nil
            
        } else {
            
            ScheduleManager.shared.getScheduleDataOnServer()
            
            mainViewSections = [.mySchedule]
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refreshController.attributedTitle = NSAttributedString(string: "資料讀取中...")
        
        refreshController.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        self.tableView.addSubview(refreshController)
        
        scheduleRef.observe(.childAdded, with: { (snapshot) in
            self.tableView.reloadData()
        })

    }

    func refreshData() {

        ScheduleManager.shared.delegate = self
        
        if isTripGroupMode {
            
            ScheduleManager.shared.getScheduleHadJoinedOnServer()
            
        } else {
            
            ScheduleManager.shared.getScheduleDataOnServer()
            
        }

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return mainViewSections.count
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch mainViewSections[section] {
            
        case .mySchedule:
            
            if schedules.count == 0 {
                
                emptyNotice.isHidden = false
                
                return 0
                
            } else {
                
                emptyNotice.isHidden = true
                
                return schedules.count
            }
            
            
        case .iAmJoining:
            
            if scheduleHadJoineds.count == 0 {
                    
                emptyNotice.isHidden = false
                    
                return 0
                    
            } else {
                    
                emptyNotice.isHidden = true
                    
                return scheduleHadJoineds.count
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleMainTableViewCell
        
        switch mainViewSections[indexPath.section] {
            
        case .mySchedule:

            cell.titleLabel.text = schedules[indexPath.row].title
            
            let startDateString = schedules[indexPath.row].createdDate
            
            let endDateString = addDaysForDate(dateString: startDateString, days: schedules[indexPath.row].days)
            
            cell.dateLabel.text = "\(startDateString) ~ \(endDateString)"
        
            cell.backgroundImageView.contentMode = .scaleAspectFill
        
            cell.backgroundImageView.sd_setImage(with: URL(string: schedules[indexPath.row].imageUrl))
        
            cell.tag = indexPath.section * 1000 + indexPath.row
        
            return cell
        
        case .iAmJoining:
            
            if self.scheduleHadJoineds.count == 0 {
                
                return cell
                
            }
            
            cell.titleLabel.text = scheduleHadJoineds[indexPath.row].title

            let startDateString = scheduleHadJoineds[indexPath.row].createdDate
            
            let endDateString = addDaysForDate(dateString: startDateString, days: scheduleHadJoineds[indexPath.row].days)
            
            cell.dateLabel.text = "\(startDateString) ~ \(endDateString)"
            
            cell.backgroundImageView.contentMode = .scaleAspectFill
            
            cell.backgroundImageView.sd_setImage(with: URL(string: scheduleHadJoineds[indexPath.row].imageUrl))
            
            cell.tag = indexPath.section * 1000 + indexPath.row
            
            return cell
            
        }
        
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let myScheduleString = NSLocalizedString("My Schedule", comment: "我的行程")
        
        let iAmJoiningString = NSLocalizedString("I am joining", comment: "目前加入的行程")
        
        switch mainViewSections[section] {
            
        case .mySchedule:
        
            return headerViewSetting(viewFrame:self.view.frame, text:myScheduleString)
            
        case .iAmJoining:
            
            return headerViewSetting(viewFrame:self.view.frame, text:iAmJoiningString)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            
        case .delete :
            
            switch mainViewSections[indexPath.section] {
                
            case .mySchedule:
                
                removeScheduleAllSnapshot(schedule: self.schedules[indexPath.row])
                
                self.schedules.remove(at: indexPath.row)
                
                self.tableView.reloadData()

            case .iAmJoining:
                
                let scheduleParnersRef = Database.database().reference().child("scheduleParners")
                
                let uid = (Auth.auth().currentUser?.uid)!
                
                let currentSchedule = self.scheduleHadJoineds[indexPath.row]
                
                let parnerRef = scheduleParnersRef.child(currentSchedule.scheduleId).child("parners")
                
                parnerRef.observeSingleEvent(of: .value, with: { (snap) in
                
                    if let values = snap.value as? [String] {
                
                        var localParnerList = values
                
                        localParnerList.enumerated().map({ (index,parnerID) in
                
                            if parnerID == uid {
                
                                localParnerList.remove(at: index)
                
                                parnerRef.setValue(localParnerList, withCompletionBlock: { (error, ref) in
                                    self.tableView.reloadData()
                                })
                
                            }
                
                        })
                    }
                })
                
                self.scheduleHadJoineds.remove(at: indexPath.row)
                
                var localSchedules: [String] = []
                
                self.scheduleHadJoineds.map({ (schedule) in
                    
                    localSchedules.append(schedule.scheduleId)
                    
                })
                
                let currentScheduleHadJoinedRef = scheduleHadJoinedRef.child(uid).child("schedules")
                
                currentScheduleHadJoinedRef.setValue(localSchedules, withCompletionBlock: { (error, ref) in
                    self.tableView.reloadData()
                })
                
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

extension ScheduleMainTableViewController: ScheduleManagerDelegate {
    
    func manager(_ manager: ScheduleManager, didget schedules: [Schedule]) {
        
        self.refreshController.endRefreshing()
        
        endLoading()
        
        self.schedules = schedules
        
        self.schedulesTableView.reloadData()
        
    }
    
    func manager( _ manager: ScheduleManager, didget hadJoinedschedules: [String] ) {
        
        self.refreshController.endRefreshing()
        
        endLoading()
        
        self.scheduleHadJoineds = []
        
        hadJoinedschedules.map { (hadJoinedschedule) in
            getSingleScheduleDataOnServer(scheduleID: hadJoinedschedule)
        }
        
        self.schedulesTableView.reloadData()
    }
    
    func manager( _ manager: ScheduleManager, didFailWith error:ScheduleManagerError ) {
        
        if error == ScheduleManagerError.snapDoesNotExist {
            
            print(error)
        }
    }
    
    func getSingleScheduleDataOnServer(scheduleID: String) {
        
        startLoading(status: "Loading")
        
        var schedule: Schedule!
        
        scheduleRef.child(scheduleID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists(){
            
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
                
            } else {
                
                print("snap not exist.")
            }

            endLoading()
        })
        
    }

}
