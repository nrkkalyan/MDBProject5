//
//  User.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/21/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import PromiseKit
import FirebaseStorage

class User: Mappable {
    var username: String?
    var name: String?
    var email: String?
    var uid: String!
    var imageUrl: String!
    var created: [String]!
    var interested: [String]!
    var image: UIImage!
    
//    init(id: String, userDict: [String:Any]?) {
//        self.uid = id
//        if userDict != nil {
//            if let name = userDict!["name"] as? String {
//                self.name = name
//            }
//            if let email = userDict!["email"] as? String {
//                self.email = email
//            }
//            if let username = userDict!["username"] as? String {
//                self.username = username
//            }
//        }
//    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        uid                     <- map["uid"]
        username                <- map["username"]
        name                    <- map["name"]
        email                   <- map["email"]
        imageUrl                <- map["imageUrl"]
        created                 <- map["created"]
        interested              <- map["interested"]
    }
    
//    static func getCurrentUser(withId: String, block: @escaping (User) -> ()) {
//        FirebaseDBClient.fetchUser(id: withId, withBlock: {(user) in
//            block(user)
//        })
//    }
    
    static func getCurrentUser(withId: String) -> Promise<User> {
        return FirebaseDBClient.fetchUser(id: withId)
    }
    
    func getEventImage(withBlock: @escaping () -> ()) {
        let ref = Storage.storage().reference().child("/Profile Images/\(uid!)")
        ref.getData(maxSize: 5 * 2048 * 2048, completion: { data, error in
            if let error = error {
                print(error)
            } else {
                self.image = UIImage(data: data!)
                withBlock()
            }
        })
    }
    
}
