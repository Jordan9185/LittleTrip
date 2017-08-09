//
//  ParnerCollectionViewController.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/9.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ParnerCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()

    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 100
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParnerPicCell", for: indexPath) as! ParnerCollectionViewCell
    
        return cell
    }

}
