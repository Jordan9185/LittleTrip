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
    
    var dailySchedules: [Int: [DailySchedule]]!
    
    var isGetFirstLocation:Bool = false
    
    var markers:[GMSMarker] = []
    
    var mapView: GMSMapView!
    
    @IBOutlet var backGroundView: UIView!
    
    @IBOutlet var markerStepper: UIStepper!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        isGetFirstLocation = false
        
        markers = []
        
        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        let navigationController = myTabBarViewController.childViewControllers[0]
        
        let previousViewController = navigationController.childViewControllers[0] as! DailyScheduleTableViewController
        
        self.dailySchedules = previousViewController.dailySchedules
        
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            
            locationManager.requestWhenInUseAuthorization()
            
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            startLoading(status: "Loading")
            
        } else {
            
            print(CLLocationManager.authorizationStatus())
            
        }
        
    }


    func setGoogleMaps(userLocation: CLLocationCoordinate2D) {

        let latitude = userLocation.latitude
        
        let longitude = userLocation.longitude

        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 8.0)
        
        mapView = GMSMapView.map(withFrame: backGroundView.frame, camera: camera)
        
        mapView.isMyLocationEnabled = true
        
        backGroundView.addSubview(mapView)
        
        let days = self.dailySchedules.count
        
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .brown]
        
        for day in 0..<days {
            
            for dailySchedule in self.dailySchedules[day]! {
                
                if (dailySchedule.coordinate.latitude == 0) && (dailySchedule.coordinate.longitude == 0) {
                    
                    continue
                    
                }
                
                var marker = GMSMarker(position: dailySchedule.coordinate)
                
                marker.title = "Day\(day + 1) \(dailySchedule.locationName)"
                
                marker.snippet = "\(dailySchedule.startTime) to \(dailySchedule.endTime)"
                
                marker.icon = GMSMarker.markerImage(with: colors[day % 5])
                    
                marker.map = mapView
                
                markers.append(marker)
            }
            
        }
        
        markerStepper.maximumValue = Double(markers.count)
        
        markerStepper.minimumValue = 1
        
        if markers.count > 0 {
            
            mapView.selectedMarker = markers.first
            
            mapView.camera = GMSCameraPosition.camera(withTarget: (markers.first?.position)!, zoom: 10)
            
        }

    }
    
    @IBAction func markerStepperValueChanged(_ sender: UIStepper) {
        
        let pointer = Int(sender.value) - 1
        
        mapView.selectedMarker = markers[pointer]
        
        mapView.camera = GMSCameraPosition.camera(withTarget: markers[pointer].position, zoom: 10)
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }

}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !isGetFirstLocation {
            
            setGoogleMaps(userLocation: (locations.first?.coordinate)!)
            
            isGetFirstLocation = true
            
        }
        
        endLoading()
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
