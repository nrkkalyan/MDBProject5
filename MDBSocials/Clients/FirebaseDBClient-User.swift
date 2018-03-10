//
//  FirebaseDBClient-User.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/27/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import PromiseKit
import FirebaseDatabase
import SwiftyJSON
import FirebaseStorage

extension FirebaseDBClient {
    
    static func createNewUser(uid: String, name: String, username: String, email: String, imageData: Data) {
        let storage = Storage.storage().reference().child("Profile Images/\(uid)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        log.info("Starting profile image storage")
        storage.putData(imageData, metadata: metadata).observe(.success) { (snapshot) in
            log.info("Profile image stored.")
            let url = snapshot.metadata?.downloadURL()?.absoluteString as! String
            
            let usersRef = Database.database().reference().child("Users")
            let newUser = ["uid": uid, "username": username, "name": name, "email": email, "imageUrl": url]
            let childUpdates = ["/\(uid)/": newUser]
            usersRef.updateChildValues(childUpdates)
        }
    }
    
    //    static func fetchUser(id: String, withBlock: @escaping (User) -> ()) {
    //        let ref = Database.database().reference()
    //        ref.child("Users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
    ////            let user = User(id: snapshot.key, userDict: snapshot.value as! [String:Any]?)
    ////            withBlock(user)
    //
    //            let json = JSON(snapshot.value)
    //            if let result = json.dictionaryObject {
    //                if let user = User(JSON: result) {
    //                    withBlock(user)
    //                }
    //            }//.catch { error in
    ////                print(error)
    ////            }
    //        })
    //    }
    
    static func fetchUser(id: String) -> Promise<User> {
        return Promise { seal in
            after(seconds: 10).done {
                seal.reject(RequestTimedOutError.requestTimedOut)
            }
            let ref = Database.database().reference()
            ref.child("Users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                let json = JSON(snapshot.value)
                if let result = json.dictionaryObject {
                    if let user = User(JSON: result) {
                        seal.fulfill(user)
                    }
                }
            })
        }
    }
    
    // if USEREVENT is true, add PID to CREATED
    // else add PID to INTERESTED
    static func updateEvents(uid: String, pid: String, userCreated: Bool) {
        let postRef = Database.database().reference().child("Users/\(uid)")
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var user = currentData.value as? [String:Any] {
                if userCreated {
                    var created: [String]
                    created = user["created"] as? [String] ?? []
                    if !created.contains(pid) {
                        created.append(pid)
                    }
                    user["created"] = created
                } else {
                    var interested: [String]
                    interested = user["interested"] as? [String] ?? []
                    if interested.contains(pid) {
                        interested.remove(at: interested.index(of: pid)!)
                    } else {
                        interested.append(pid)
                    }
                    user["interested"] = interested.count != 0 ? interested : [String]()
                }
                currentData.value = user
            }
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { (error, commited, snapshot) in
            if let error = error {
                log.error(error.localizedDescription)
            } else {
                if var user = snapshot?.value as? [String:Any] {
                    // do something?
                }
            }
        })
    }
    
}
