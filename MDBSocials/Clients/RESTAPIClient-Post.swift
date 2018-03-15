//
//  RESTAPIClient-Post.swift
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
    
    static func fetchPost(pid: String) -> Promise<Post> {
        return Promise { seal in
            after(seconds: 10).done {
                seal.reject(RequestTimedOutError.requestTimedOut)
            }
            let endpoint = "https://mdbsocial.herokuapp.com/posts/\(pid)"
            Alamofire.request(endpoint, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON().done { response -> Void in
                let json = JSON(response.json)
                if var result = json.dictionaryObject {
                    var interested = [String]()
                    if let rInterested = result["interested"] {
                        for event in (rInterested as! Dictionary<String,Any>).values {
                            interested.append(event as! String)
                        }
                        result["interested"] = interested
                    }
                    log.info(result)
                    if let post = Post(JSON: result) {
                        seal.fulfill(post)
                    }
                }
            }
        }
    }
    
    static func fetchPosts() -> Promise<[Post]> {
        return Promise { seal in
            after(seconds: 10).done {
                seal.reject(RequestTimedOutError.requestTimedOut)
            }
            log.info("Fetching posts.")
            let endpoint = "https://mdbsocial.herokuapp.com/posts"
            Alamofire.request(endpoint, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON().done { response -> Void in
                let result = JSON(response.json)
                var posts = [Post]()
                for post in result {
                    let post = post.1.dictionaryObject!
                    log.info(post)
                    if let post = Post(JSON: post) {
                        posts.append(post)
                    }
                }
                seal.fulfill(posts)
                log.info("Finished fetching posts.")
            }
        }
    }
    
    static func updateInterestedCounter(uid: String, pid: String) -> Promise<[String]> {
        return Promise { seal in
            let endpoint = "https://mdbsocial.herokuapp.com/posts/\(pid)/interested"
            let requestParams: [String : Any] = ["userId": uid]
            Alamofire.request(endpoint, method: .patch, parameters: requestParams, encoding: URLEncoding.default, headers: nil).responseJSON().done { response -> Void in
                let result = JSON(response.json).arrayObject as! [String]
                log.info(result)
                seal.fulfill(result)
            }
        }
    }
    
    static func createNewPost(name: String, description: String, location: String, date: String, imageData: Data, host: String, hostId: String) {
        
        let endpoint = "https://mdbsocial.herokuapp.com/posts"
        let postRequestParams: [String : Any] = [
            "name": name,
            "description": description,
            "location": location,
            "date": date,
            "host": host,
            "hostId": hostId,
            "interested": [hostId]
        ]
        Alamofire.request(endpoint, method: .post, parameters: postRequestParams, encoding: URLEncoding.default, headers: nil).responseJSON().done { response -> Void in
            let json = JSON(response.json)
            if let result = json.dictionaryObject {
                let pid = result["postId"]!
                
                let storage = Storage.storage().reference().child("Event Images/\(pid)")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                log.info("Starting event image storage.")
                storage.putData(imageData, metadata: metadata).observe(.success) { (snapshot) in
                    log.info("Event image stored.")
                    let url = snapshot.metadata?.downloadURL()?.absoluteString as! String
                    
                    let endpoint = "https://mdbsocial.herokuapp.com/posts/\(pid)/imageUrl"
                    let requestParams: [String : Any] = ["url": url]
                    Alamofire.request(endpoint, method: .patch, parameters: requestParams, encoding: URLEncoding.default, headers: nil).responseJSON().done { response -> Void in
                        let json = JSON(response.json)
                        log.info(json)
                        if let result = json.dictionaryObject {
                            log.info(result)
                            var newPost = postRequestParams
                            newPost["imageUrl"] = url
                            newPost["postId"] = pid
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPost"), object: nil, userInfo: newPost)
                        }
                    }.catch { error in
                        log.error(error.localizedDescription)
                    }
                }
            }
        }.catch { error in
            log.error(error.localizedDescription)
        }
    }
    
}
