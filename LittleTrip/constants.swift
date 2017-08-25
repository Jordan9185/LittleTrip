//
//  constants.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/15.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import Foundation

import FirebaseDatabase

let googleProjectApiKey = "AIzaSyAtMVBle_WPgL3OBV310VsVG8AFjoFDheA"

let googlePlacesApiKey = "AIzaSyCi5NP6Ywvkqv3l223BJX2u6oG_nZ4z4NU"

let dataBaseRef = Database.database().reference()

let scheduleRef = dataBaseRef.child("schedule")

let scheduleHadJoinedRef = dataBaseRef.child("scheduleHadJoined")

let dailyScheduleRef = dataBaseRef.child("dailySchedule")

let baggageListRef = dataBaseRef.child("baggageList")

let parnerRef = dataBaseRef.child("scheduleParners")

let userRef = dataBaseRef.child("user")
