//
//  FirebaseAPIClient.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/21/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import FirebaseDatabase
import UIKit

class FirebaseAPIClient {
    
    static func fetchUser(username: String, withBlock: @escaping (User) -> ()) {
        let ref = Database.database().reference()
        ref.child("Users").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
            let user = User(username: snapshot.key, userDict: snapshot.value as! [String:Any]?)
            withBlock(user)
        })
    }
    
    static func createNewPost(name: String, description: String, date: Date, image: UIImage, host: String) {
        let postsRef = Database.database().reference().child("Posts")
        let newPost = ["name": name, "description": description, "date": date, "image": image, "host": host] as [String : Any]
        let key = postsRef.childByAutoId().key
        let childUpdates = ["/\(key)/": newPost]
        postsRef.updateChildValues(childUpdates)
    }
    
    static func createNewUser(name: String, username: String, email: String) {
        let usersRef = Database.database().reference().child("Users")
        let newUser = ["username": username, "name": name, "email": email]
        let childUpdates = ["/\(username)/": newUser]
        usersRef.updateChildValues(childUpdates)
    }
}

