//
//  constants.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/15.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import Foundation

import FirebaseDatabase

let dataBaseRef = Database.database().reference()

let scheduleRef = dataBaseRef.child("schedule")

let scheduleHadJoinedRef = dataBaseRef.child("scheduleHadJoined")

let dailyScheduleRef = dataBaseRef.child("dailySchedule")

let baggageListRef = dataBaseRef.child("baggageList")
