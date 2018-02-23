//
//  FirebaseAPIClient.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/21/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import UIKit

class FirebaseAPIClient {
    
    static func updatePost(withBlock: @escaping (Post) -> ()) {
        let ref = Database.database().reference().child("Posts")
        ref.observe(.childChanged, with: { (snapshot) in
            let post = Post(id: snapshot.key, postDict: snapshot.value as! [String:Any]?)
            withBlock(post)
        })
    }
    
    static func updateInterestedCounter(uid: String, pid: String, withBlock: @escaping ([String]) -> ()) {
        let postRef = Database.database().reference().child("Posts/\(pid)")
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String:Any] {
                var interested: [String]
                interested = post["interested"] as? [String] ?? []
                if interested.contains(uid) {
                    interested.remove(at: interested.index(of: uid)!)
                } else {
                    interested.append(uid)
                }
                post["interested"] = interested.count != 0 ? interested : [String]()
                currentData.value = post
            }
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { (error, commited, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if var post = snapshot?.value as? [String:Any] {
                    let interested = post["interested"] as? [String] ?? []
                    withBlock(interested)
                }
            }
        })
    }
    
    static func fetchPosts(withBlock: @escaping (Post) -> ()) {
        let ref = Database.database().reference()
        ref.child("Posts").observe(.childAdded, with: { (snapshot) in
            let post = Post(id: snapshot.key, postDict: snapshot.value as! [String : Any]?)
            withBlock(post)
        })
    }
    
    static func fetchUser(id: String, withBlock: @escaping (User) -> ()) {
        let ref = Database.database().reference()
        ref.child("Users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            let user = User(id: snapshot.key, userDict: snapshot.value as! [String:Any]?)
            withBlock(user)
        })
    }
    
    static func createNewPost(name: String, description: String, date: String, imageData: Data, host: String, hostId: String) {
        
        let postsRef = Database.database().reference().child("Posts")
        let key = postsRef.childByAutoId().key
        
        let storage = Storage.storage().reference().child("Event Images/\(key)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        print("starting image storage")
        storage.putData(imageData, metadata: metadata).observe(.success) { (snapshot) in
            print("image stored")
            let url = snapshot.metadata?.downloadURL()?.absoluteString as! String
            
            let interested = [hostId]
            let newPost = ["name": name, "description": description, "date": date, "imageUrl": url, "host": host, "hostId": hostId, "interested": interested] as [String : Any]
            let childUpdates = ["/\(key)/": newPost]
            postsRef.updateChildValues(childUpdates)
        }
    }
    
    static func createNewUser(uid: String, name: String, username: String, email: String) {
        let usersRef = Database.database().reference().child("Users")
        let newUser = ["username": username, "name": name, "email": email]
        let childUpdates = ["/\(uid)/": newUser]
        usersRef.updateChildValues(childUpdates)
    }
}

