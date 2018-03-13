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
    
}
