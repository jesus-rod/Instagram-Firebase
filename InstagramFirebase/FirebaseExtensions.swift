//
//  FirebaseExtensions.swift
//  InstagramFirebase
//
//  Created by Jesus Adolfo on 5/6/17.
//  Copyright © 2017 jesus. All rights reserved.
//

import Firebase

extension FIRDatabase {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        print("Fetching user with uid", uid)
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictonary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictonary)
            
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user at home", err)
        }
        
    }
}
