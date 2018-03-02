//
//  FOAASClient.swift
//  MDBSocials
//
//  Created by Tiger Chen on 3/2/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class FOAASClient {
    
    static func getFO(input: String) -> Promise<String> {
        return Promise { seal in
            after(seconds: 10).done {
                seal.reject(RequestTimedOutError.requestTimedOut)
            }
            let endpoint = "https://www.foaas.com/\(input)/name"
            
            Alamofire.request(endpoint, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Accept": "application/json"]).responseJSON().done { response -> Void in
                print(response.json)
                let json = JSON(response.json)
                if let result = json.dictionaryObject {
                    seal.fulfill(result["message"] as! String)
                }
            }.catch { error in
                print(error.localizedDescription)
                seal.reject(error)
            }
        }
    }
    
}
