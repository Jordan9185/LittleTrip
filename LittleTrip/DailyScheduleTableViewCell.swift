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
    
    @IBOutlet var travelTimeLabel: UILabel!
    
    var dailyScheduleRef: DatabaseReference?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        self.startTimeTextField.delegate = self
        
        self.endTimeTextField.delegate = self
        
        let startTimePicker = UIDatePicker()
        
        let endTimePicker = UIDatePicker()
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 40))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [ flexibleSpace, doneButton ]

        startTimePicker.datePickerMode = .time
        
        endTimePicker.datePickerMode = .time
        
        self.startTimeTextField.inputView = startTimePicker
        
        self.endTimeTextField.inputView = endTimePicker
        
        self.startTimeTextField.inputAccessoryView = toolbar
        
        self.endTimeTextField.inputAccessoryView = toolbar
        
        startTimePicker.addTarget(self, action: #selector(startTimeChange), for: .valueChanged)
        
        endTimePicker.addTarget(self, action: #selector(endTimeChange), for: .valueChanged)
        
    }

    func doneButtonTapped() {
        
        textFieldShouldReturn(self.startTimeTextField)
        
        textFieldShouldReturn(self.endTimeTextField)
        
        self.startTimeTextField.resignFirstResponder()
        
        self.endTimeTextField.resignFirstResponder()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

    }
    
    func startTimeChange(_ sender: UIDatePicker) {
        
        print(sender.date)
        
        let calender = Calendar.current
        
        let hour = calender.component(.hour, from: sender.date)
        
        let min = calender.component(.minute, from: sender.date)
        
        self.startTimeTextField.text = "\(hour):\(min)"
        
    }
    
    func endTimeChange(_ sender: UIDatePicker) {
        
        print(sender.date)
        
        let calender = Calendar.current
        
        let hour = calender.component(.hour, from: sender.date)
        
        let min = calender.component(.minute, from: sender.date)
        
        self.endTimeTextField.text = "\(hour):\(min)"
        
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
