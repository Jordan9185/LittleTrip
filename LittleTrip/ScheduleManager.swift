//
//  ScheduleManager.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/15.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct Schedule {
    
    let title: String
    
    let days: Int
    
    let createdDate: String
    
    let uid: String
    
    let imageUrl: String
    
    let scheduleId: String
    
}

enum ScheduleManagerError: Error {
    
    case snapDoesNotExist
}

protocol ScheduleManagerDelegate: class {
    
    func manager( _ manager: ScheduleManager, didget schedules: [Schedule] )
    
    func manager( _ manager: ScheduleManager, didget hadJoinedschedules: [String] )
    
    func manager( _ manager: ScheduleManager, didFailWith error:ScheduleManagerError )
    
}

class ScheduleManager {
    
    static let shared = ScheduleManager()
    
    weak var delegate: ScheduleManagerDelegate?
    
    let scheduleRef = Database.database().reference().child("schedule")
    
    let scheduleHadJoinedRef = Database.database().reference().child("scheduleHadJoined")
    
    func getScheduleDataOnServer() {
        
        let uid = (Auth.auth().currentUser?.uid)!
        
        let ref = scheduleRef.queryOrdered(byChild: "uid").queryEqual(toValue: uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
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
                
                self.delegate?.manager(self, didget: localSchedules)
                
            }
            
        })
        
    }
    
    
    func getScheduleHadJoinedOnServer() {
        
        let uid = (Auth.auth().currentUser?.uid)!
        
        let personalScheduleHadJoinedRef = scheduleHadJoinedRef.child(uid).child("schedules")
        
        personalScheduleHadJoinedRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                if let values = snapshot.value as? [String] {
                    
                    self.delegate?.manager(self, didget: values)
                    
                }
                
            } else {
                
                self.delegate?.manager(self, didFailWith: ScheduleManagerError.snapDoesNotExist)
                
            }
            
        })
        
    }

}
