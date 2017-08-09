//
//  ParnerBoardTableViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/9.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

class ParnerBoardTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParnerCell", for: indexPath) as! ParnerBoardTableViewCell



        return cell
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }

}
