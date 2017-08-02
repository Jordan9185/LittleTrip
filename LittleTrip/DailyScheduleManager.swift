//
//  DailyScheduleManager.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/2.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreLocation

protocol DailyScheduleManagerDelegate: class {
    
    func manager(_ manager:DailyScheduleManager, didGet dailySchedules: [[Int:[DailySchedule]]])
    
    func manager(_ manager:DailyScheduleManager, didFailWith error: Error)
    
}

class DailyScheduleManager {
    
    weak var delegate:DailyScheduleManagerDelegate?
    
    func catchDailySchedules(_ scheduleId: String) {
        
        var result: [[Int:[DailySchedule]]] = []
        
        let dailyScheduleRef = Database.database().reference().child("dailySchedule").child(scheduleId)
        
        dailyScheduleRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
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

                    result.append([index:snapshotValuesArray])
                    
                }
                
                self.delegate?.manager(self, didGet: result)
                
            }
        })
        
    }
    
}
