//
//  BaggageListTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/1.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

class BaggageListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "baggageCell", for: indexPath) as! BaggageListTableViewCell

        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        
        button.setTitle("+ Add item ...", for: .normal)
        
        footerView.addSubview(button)
        
        footerView.backgroundColor = .brown
        
        return footerView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 50
        
    }
    
}
