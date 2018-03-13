//
//  RESTAPIClient-User.swift
//  MDBSocials
//
//  Created by Tiger Chen on 3/12/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON
import ObjectMapper
import FirebaseStorage

extension RESTAPIClient {
    
    static func createNewUser(uid: String, name: String, username: String, email: String, imageData: Data) {
        
        let storage = Storage.storage().reference().child("Profile Images/\(uid)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        log.info("Starting profile image storage")
        storage.putData(imageData, metadata: metadata).observe(.success) { (snapshot) in
            log.info("Profile image stored.")
            let url = snapshot.metadata?.downloadURL()?.absoluteString as! String

            let endpoint = "https://mdbsocial.herokuapp.com/users/\(uid)"
            let requestParameters: [String : Any] = [
                "name": name,
                "username": username,
                "email": email,
                "imageUrl": url
            ]
            Alamofire.request(endpoint, method: .post, parameters: requestParameters, encoding: URLEncoding.default, headers: nil).responseJSON().done { response -> Void in
                log.info(response.json)
                }.catch { error in
                    log.error(error.localizedDescription)
            }
        }
    }
    
    static func fetchUser(id: String) -> Promise<User> {
        return Promise { seal in
            after(seconds: 10).done {
                seal.reject(RequestTimedOutError.requestTimedOut)
            }
            let endpoint = "https://mdbsocial.herokuapp.com/users/\(id)"
            Alamofire.request(endpoint, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON().done { response -> Void in
                var json = JSON(response.json)
                if var result = json.dictionaryObject {
                    var interested = [String]()
                    if let rInterested = result["interested"] {
                        for event in (rInterested as! Dictionary<String,Any>).values {
                            interested.append(event as! String)
                        }
                        result["interested"] = interested
                    }
                    var created = [String]()
                    if let rCreated = result["created"] {
                        for event in (rCreated as! Dictionary<String,Any>).values {
                            created.append(event as! String)
                        }
                        result["created"] = created
                    }
                    log.info(result)
                    if let user = User(JSON: result) {
                        seal.fulfill(user)
                    }
                }
            }
        }
    }
    
}
