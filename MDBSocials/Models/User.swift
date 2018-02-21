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
    
    init(username: String, userDict: [String:Any]?) {
        self.username = username
        if userDict != nil {
            if let name = userDict!["name"] as? String {
                self.name = name
            }
            if let email = userDict!["email"] as? String {
                self.email = email
            }
        }
    }
    
    static func getCurrentUser(withUsername: String, block: @escaping (User) -> ()) {
        FirebaseAPIClient.fetchUser(username: withUsername, withBlock: {(user) in
            block(user)
        })
    }
    
}
