//
//  DailyScheduleTableViewCell.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/7/28.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

import FirebaseDatabase

class DailyScheduleTableViewCell: UITableViewCell {

    @IBOutlet var startTimeTextField: UITextField!
    
    @IBOutlet var endTimeTextField: UITextField!
    
    @IBOutlet var locationNameLabel: UILabel!
    
    var dailyScheduleRef: DatabaseReference?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        self.startTimeTextField.delegate = self
        
        self.endTimeTextField.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

    }

}

extension DailyScheduleTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let indexPath = IndexPath(row: textField.tag % 1000, section: textField.tag / 1000)
        
        switch textField {
            
        case self.startTimeTextField:

            let updateDic: [String:Any] = {
                [
                    "startTime" : textField.text ?? "08:00"
                ]
            }()
            
            let currentDailyScheduleRef = self.dailyScheduleRef?.child("\(indexPath.section)").child("\(indexPath.row)")
            
            currentDailyScheduleRef?.updateChildValues(updateDic)
            
        case self.endTimeTextField:
            
            let updateDic: [String:Any] = {
                [
                    "endTime" : textField.text ?? "08:00"
                ]
            }()
            
            let currentDailyScheduleRef = self.dailyScheduleRef?.child("\(indexPath.section)").child("\(indexPath.row)")
            
            currentDailyScheduleRef?.updateChildValues(updateDic)
            
        default:
            
            print("unknowTextfield: \(textField)")
            
        }
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
}
