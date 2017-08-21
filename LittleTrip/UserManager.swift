//
//  UserManager.swift
//  LittleTrip
//
//  Created by JordanLin on 2017/8/21.
//  Copyright © 2017年 JordanLin. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

enum UserError:Error {
    
    case catchNameError
    
    case catchImageURLError
    
    case catchEmailError
    
}
protocol UserManagerDelegate: class {
    
    func manager(_ manager:UserManager, didGet parnerList: [User])
    
    func manager(_ manager:UserManager, didFailWith error: UserError)
}

class UserManager {
 
    static let shared = UserManager()
    
    weak var delegate: UserManagerDelegate?
    
    func catchParnerList(scheduleID: String) {
        
        startLoading(status: "Loading")
        
        parnerRef.child(scheduleID).child("parners").observe(.value, with: { (snapshot) in
            
            var users: [User] = []
            
            if let parners = snapshot.value as? [String] {
                
                parners.map({ (parnerString) in
                    
                    self.catchUserData(userID: parnerString, completion: { (user, error) in
                        
                        if let error = error {
                            
                            endLoading()
                            
                            self.delegate?.manager(self, didFailWith: error)
                            
                            return
                        }

                        users.append(user!)
                        
                        if users.count == parners.count {
                            
                            endLoading()
                            
                            self.delegate?.manager(self, didGet: users)
                        }
                        
                    })
                    
                })
                
            }
            
            endLoading()
            
        })
        
    }
    
    typealias CompletionHandler = (_ user: User?,_ error: UserError?) -> Void
    
    func catchUserData(userID: String, completion:@escaping CompletionHandler) {
        
        userRef.child(userID).observeSingleEvent(of: .value, with: { (snap) in
            
            if let values = snap.value as? [String:Any] {
                
                guard let name = values["name"] as? String else {
                    
                    completion(nil, UserError.catchNameError)
                    
                    return
                    
                }
                
                guard let imageURL = values["imageURL"] as? String else {
                    
                    completion(nil, UserError.catchImageURLError)
                    
                    return
                    
                }
                
                guard let email = values["email"] as? String else {
                    
                    completion(nil, UserError.catchEmailError)
                    
                    return
                    
                }
                
                let user = User(
                    uid: userID,
                    name: name,
                    pictureURL: imageURL,
                    email: email
                )
                
                completion(user, nil)
                
            }
            
        })
    }

}
