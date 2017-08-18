//
//  AppDelegate.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/25.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleMaps
import GooglePlaces
import SlideMenuControllerSwift
import SVProgressHUD

let googleProjectApiKey = "AIzaSyBF5_QyFXAgL9vYzLSrAPbHxGxH1c9wynE"

let googlePlacesApiKey = "AIzaSyADccF3vuF1U0x3x0BSRqOJTz3rmUqmksc"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var handle: AuthStateDidChangeListenerHandle?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey(googleProjectApiKey)
        
        GMSPlacesClient.provideAPIKey(googleProjectApiKey)
        
        FirebaseApp.configure()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            
            if let user = user {
                
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainFlow")
                
                let leftViewController = storyboard.instantiateViewController(withIdentifier: "Left")
                
                let slideMenuController = SlideMenuController(mainViewController: mainViewController, leftMenuViewController: leftViewController)
                
                UIApplication.shared.statusBarStyle = .lightContent
                
                self.window?.rootViewController = slideMenuController
                
            } else {
                
                let nextViewController = storyboard.instantiateViewController(withIdentifier: "LoginFlow")
                
                self.window?.rootViewController = nextViewController
                
            }
            
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        Auth.auth().addStateDidChangeListener { auth, user in
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            
            if let user = user {
                
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainFlow")
                
                let leftViewController = storyboard.instantiateViewController(withIdentifier: "Left")
                
                let slideMenuController = SlideMenuController(mainViewController: mainViewController, leftMenuViewController: leftViewController)
                
                UIApplication.shared.statusBarStyle = .lightContent
                
                self.window?.rootViewController = slideMenuController
                
            } else {
                
                let nextViewController = storyboard.instantiateViewController(withIdentifier: "LoginFlow")
                
                self.window?.rootViewController = nextViewController
                
            }
            
        }
    
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

