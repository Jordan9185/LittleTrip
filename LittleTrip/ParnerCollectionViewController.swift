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

class ParnerCollectionViewController: UICollectionViewController {
    
    var parnerLists: [User] = []
    
    let parnerRef = Database.database().reference().child("scheduleParners")
    
    let userRef = Database.database().reference().child("user")
    
    var currentSchedule: Schedule!
    
    let sections:[CollectionViewSection] = [.host, .parner]
    
    var scheduleHost: User!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        catchParnerList()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        parnerRef.removeAllObservers()
        
    }
    
    func catchParnerList() {
        
        startLoading()
        
        parnerRef.child(currentSchedule.scheduleId).child("parners").observe(.value, with: { (snapshot) in
            
            if let parners = snapshot.value as? [String] {
                
                var users: [User] = []
                
                parners.map({ (parnerString) in
                    
                    startLoading()
                    
                    self.userRef.child(parnerString).observeSingleEvent(of: .value, with: { (snap) in
                        
                        if let values = snap.value as? [String:Any] {
                            
                            guard let name = values["name"] as? String else {
                                
                                return
                                
                            }
                            
                            guard let imageURL = values["imageURL"] as? String else {
                                
                                return
                                
                            }
                            
                            users.append(
                                User(
                                    uid: parnerString,
                                    name: name,
                                    pictureURL: imageURL
                                )
                            )
                            
                        }
                        
                        self.parnerLists = users
                        
                        self.collectionView?.reloadData()
                        
                        endLoading()
                    })
                    
                })

            }
            
            endLoading()
            
        })
        
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
