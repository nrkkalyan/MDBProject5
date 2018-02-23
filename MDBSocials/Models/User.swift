//
//  User.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/21/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import UIKit

class User {
    var username: String?
    var name: String?
    var email: String?
    var uid: String!
    
    init(id: String, userDict: [String:Any]?) {
        self.uid = id
        if userDict != nil {
            if let name = userDict!["name"] as? String {
                self.name = name
            }
            if let email = userDict!["email"] as? String {
                self.email = email
            }
            if let username = userDict!["username"] as? String {
                self.username = username
            }
        }
    }
    
    static func getCurrentUser(withId: String, block: @escaping (User) -> ()) {
        FirebaseAPIClient.fetchUser(id: withId, withBlock: {(user) in
            block(user)
        })
    }
    
}
