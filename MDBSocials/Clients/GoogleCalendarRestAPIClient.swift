//
//  GoogleCalendarRestAPIClient.swift
//  MDBSocials
//
//  Created by Tiger Chen on 3/1/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import SwiftyJSON
import GoogleSignIn

class GoogleCalendarRestAPIClient {
    
    static func addEvent(post: Post) -> Promise<Bool> {
        return Promise { seal in
            after(seconds: 10).done {
                seal.reject(RequestTimedOutError.requestTimedOut)
            }
            let endpoint = "https://www.googleapis.com/calendar/v3/calendars/"
        }
    }
    
    static func getEvents() {
        let endpoint = "https://www.googleapis.com/calendar/v3/calendars/primary/events"
        let params: [String:Any] = ["orderBy": "startTime"]
        Alamofire.request(endpoint, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON().done { response -> Void in
            log.info("got a response: \(response)")
            let json = JSON(response)
            if let result = json.dictionaryObject {
                log.info("result: \(result)")
            }
            GIDSignIn.sharedInstance().signOut()
        }
    }
    
}
