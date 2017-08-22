//
//  ParnerCollectionViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/9.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

enum CollectionViewSection {
    
    case host
    
    case parner
}

class ParnerCollectionViewController: UICollectionViewController, UserManagerDelegate {
    
    var parnerLists: [User] = []
    
    var currentSchedule: Schedule!
    
    let sections:[CollectionViewSection] = [.host, .parner]
    
    var scheduleHost: User!
    
    let userManager = UserManager()
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        userManager.delegate = self
        
        userManager.catchParnerList(scheduleID: currentSchedule.scheduleId)
        
    }
    
    func manager(_ manager:UserManager, didGet parnerList: [User]){
        
        self.parnerLists = parnerList
        
        collectionView?.reloadData()
    }
    
    func manager(_ manager:UserManager, didFailWith error: UserError){
        
        print(error)
    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return sections.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch sections[section] {
            
        case .host:
            
            return 1
            
        case .parner:
            
            return self.parnerLists.count
            
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParnerPicCell", for: indexPath) as! ParnerCollectionViewCell
        
        switch sections[indexPath.section] {
            
        case .host:
            
            let hostName = scheduleHost?.name
            
            let hostImageURL = URL(string: (scheduleHost?.pictureURL)!)
            
            cell.parnerPicImageView.sd_setImage(with: hostImageURL)
            
            cell.parnerPicImageView.contentMode = .scaleAspectFill
            
            cell.userLabel.text = hostName
            
        case .parner:
            
            cell.parnerPicImageView.sd_setImage(with: URL(string: self.parnerLists[indexPath.row].pictureURL))
            
            cell.parnerPicImageView.contentMode = .scaleAspectFill
            
            cell.userLabel.text = self.parnerLists[indexPath.row].name
            
        }
        
        return cell
    }

}
