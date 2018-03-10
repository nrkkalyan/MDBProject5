//
//  UserAuthHelper.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/21/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import FirebaseAuth
import PromiseKit

class UserAuthHelper {
    
    static func logIn(email: String, password: String, withBlock: @escaping () -> ()) {
        log.info("Logging in.")
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                log.info("Logged in.")
                withBlock()
            } else {
                log.error((error?.localizedDescription)!)
                if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch errorCode {
                        case .invalidEmail:
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlert"), object: nil, userInfo: ["title": "Invalid Email", "message": "Input valid email."])
                        case .userNotFound:
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlert"), object: nil, userInfo: ["title": "Invalid Email", "message": "No user record corresponding to this email."])
                        case .wrongPassword:
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlert"), object: nil, userInfo: ["title": "Invalid Password", "message": "Password does not match email."])
                        default:
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlert"), object: nil, userInfo: ["title": "Error", "message": "Check input values."])
                    }
                }
            }
        })
    }
    
    static func logOut(withBlock: @escaping () -> ()) {
        log.info("Logging out.")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            log.info("Logged out.")
            withBlock()
        } catch let signOutError as NSError {
            log.error(signOutError.localizedDescription)
        }
    }
    
    static func createUser(email: String, password: String) -> Promise<String> {
        return Promise { seal in
            log.info("Creating new user.")
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    log.info("New user successfully created.")
                    seal.fulfill((user?.uid)!)
                } else {
                    log.error((error?.localizedDescription)!)
                    if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                        switch errorCode {
                        case .invalidEmail:
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlert"), object: nil, userInfo: ["title": "Invalid Email", "message": "Input valid email."])
                        case .emailAlreadyInUse:
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlert"), object: nil, userInfo: ["title": "Invalid Email", "message": "Email already in use."])
                        case .weakPassword:
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlert"), object: nil, userInfo: ["title": "Invalid Password", "message": "The password must be 6 characters long or more."])
                        default:
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlert"), object: nil, userInfo: ["title": "Error", "message": "Check input values."])
                        }
                    }
                }
            })
        }
    }
}
