//
//  BaggageListTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/1.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

import FirebaseDatabase

struct BaggageItem {
    
    var itemName: String
    
    var isSelected: Bool
    
}

class BaggageListTableViewController: UITableViewController {
    
    var currentSchedule: Schedule!
    
    var BaggageRef: DatabaseReference?
    
    var baggageItems: [BaggageItem] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let myTabBarViewController = self.tabBarController as! DailyTabBarViewController
        
        currentSchedule = myTabBarViewController.schedule!
        
        getBaggageListFromServer()
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()

    }

    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func getBaggageListFromServer() {
        
        BaggageRef = Database.database().reference().child("baggageList").child(currentSchedule.scheduleId)
        
        BaggageRef?.observe(.value, with: { (snapshot) in
            
            var baggageitems: [BaggageItem] = []
            
            if let items = snapshot.value as? [[String:Any]] {
                
                for item in items {
                    
                    baggageitems.append(
                        BaggageItem(
                            itemName: item["itemName"] as! String,
                            isSelected: item["isSelected"] as! Bool
                        )
                    )
                    
                }
                
                self.baggageItems = baggageitems
                
                self.tableView.reloadData()
            }
            
        })
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.baggageItems.count
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "baggageCell", for: indexPath) as! BaggageListTableViewCell

        let currentItem = self.baggageItems[indexPath.row]
        
        cell.itemNameTextField.text = currentItem.itemName
        
        cell.itemNameTextField.delegate = self
        
        cell.itemNameTextField.tag = indexPath.row
        
        if currentItem.isSelected {
            
            cell.checkboxImageView.image = #imageLiteral(resourceName: "check-box")
            
        } else {
            
            cell.checkboxImageView.image = #imageLiteral(resourceName: "check-box-empty")
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        
        button.setTitle("+ Add item ...", for: .normal)
        
        button.addTarget(self, action: #selector(addEmptyRowAction), for: .touchUpInside)
        
        footerView.addSubview(button)
        
        footerView.backgroundColor = .brown
        
        return footerView
        
    }
    
    func addEmptyRowAction(_ sender: UIButton) {
        
        self.baggageItems.append(
            BaggageItem(
                itemName: "New item",
                isSelected: false
            )
        )
        
        self.tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 50
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.baggageItems[indexPath.row].isSelected == true {
            
            self.baggageItems[indexPath.row].isSelected = false
            
        } else {
            
            self.baggageItems[indexPath.row].isSelected = true
        }
        
        tableView.reloadData()
    }
    
    @IBAction func saveItemsToServerTapped(_ sender: UIBarButtonItem) {
        
        for (index, item) in self.baggageItems.enumerated() {
         
            let ref = self.BaggageRef?.child("\(index)")
            
            let updateDic: [String:Any] = [
                    "isSelected": item.isSelected,
                    "itemName": item.itemName
            ]
            
            ref?.updateChildValues(updateDic)
            
        }
        
    }
    
}

extension BaggageListTableViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let currentRow = textField.tag
        
        self.baggageItems[currentRow].itemName = textField.text!
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
}
