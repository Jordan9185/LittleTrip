//
//  MapViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/28.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController{

    var locationManager = CLLocationManager()
    
    var dailySchedules: [Int: [DailySchedule]] = [:]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        self.dailySchedules = myTabBarViewController.dailySchedules
        
        setGoogleMaps()
        
    }

    func setGoogleMaps() {
        
        let location = self.dailySchedules[0]?[0].coordinate

        let latitude = location?.latitude
        
        let longitude = location?.longitude

        let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 7.0)
        
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView.isMyLocationEnabled = true
        
        view = mapView
        
        let days = self.dailySchedules.count
        
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .brown]
        
        for day in 0..<days {
            
            for dailySchedule in self.dailySchedules[day]! {
                
                if (dailySchedule.coordinate.latitude == 0) && (dailySchedule.coordinate.longitude == 0) {
                    
                    continue
                    
                }
                
                let maker = GMSMarker(position: dailySchedule.coordinate)
                
                maker.title = "Day\(day + 1) \(dailySchedule.locationName)"
                
                maker.snippet = "\(dailySchedule.startTime) to \(dailySchedule.endTime)"
                
                maker.icon = GMSMarker.markerImage(with: colors[day % 5])
                    
                maker.map = mapView
                
            }
            
        }
        
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }

}
