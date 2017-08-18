//
//  File.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/17.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct User {
    
    let uid: String
    
    let name: String
    
    let pictureURL: String
    
    let email: String
    
    let friendList: [String]
}

enum UserManagerError:Error {
    
    case userDataIsNil
    
    case userNameIsNil
    
    case userEmailIsNil
    
    case userimageURLIsNil
    
    case userFriendListIsNil
    
}

enum UserManagerIdentification {
    
    case friend
    
    case user
    
}

protocol UserManagerDelegate: class {
    
    func manager( _ manager: UserManager, didGet user: User)
    
    func manager( _ manager: UserManager, didFailWith error: UserManagerError )
    
}

class UserManager {
    
    static let shared = UserManager()
    
    weak var delegate: UserManagerDelegate?

    var identification: UserManagerIdentification = .user
    
    func catchUserData(userID: String) {
    
        startLoading(status: "Loading")
    
        let currendUserRef = userRef.child(userID)
        
        currendUserRef.observeSingleEvent(of: .value, with: { (snapshot) in

            if let userData = snapshot.value as? [String:Any]{
                
                guard let userName = userData["name"] as? String else {
                    
                    self.delegate?.manager(self, didFailWith: .userNameIsNil)
                    
                    return
                    
                }
                
                guard let userEmail = userData["email"] as? String else {
                    
                    self.delegate?.manager(self, didFailWith: .userEmailIsNil)
                    
                    return
                    
                }
                
                guard let userImageURL = userData["imageURL"] as? String else {
                    
                    self.delegate?.manager(self, didFailWith: .userEmailIsNil)
                    
                    return
                    
                }
                
                guard let userFriendList = userData["friendList"] as? [String] else {
                    
                    self.delegate?.manager(self, didFailWith: .userFriendListIsNil)
                    
                    return
                    
                }
                
                self.delegate?.manager(self, didGet:
                    User(
                        uid: userID,
                        name: userName,
                        pictureURL: userImageURL,
                        email: userEmail,
                        friendList: userFriendList
                    )
                )
                
            }
            
        })

    
    }
    
}
