//
//  UserAuthHelper.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/21/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import FirebaseAuth

class UserAuthHelper {
    
    static func logIn(email: String, password: String, withBlock: @escaping () -> ()) {
        print("logging in")
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                print("logged in")
                withBlock()
            } else {
                print("Error signing in: %@", error.debugDescription)
            }
        })
    }
    
    static func logOut(withBlock: @escaping () -> ()) {
        print("logging out")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("logged out")
            withBlock()
        } catch let signOutError as NSError {
            print("Error singing out: %@", signOutError)
        }
    }
    
    static func createUser(email: String, password: String, withBlock: @escaping () -> ()) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                print("no error?")
                withBlock()
            } else {
                print("Error creating user: %@", error.debugDescription)
            }
        })
    }
}
