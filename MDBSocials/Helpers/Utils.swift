//
//  Utils.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/22/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import Haneke

class Utils {
    
    static func getImage(withUrl: String) -> Promise<UIImage> {
        return Promise { seal in
            let cache = Shared.imageCache
            if let imageUrl = withUrl.toURL() {
                cache.fetch(URL: imageUrl as URL).onSuccess({ img in
                    seal.fulfill(img)
                })
            }
        }
    }
    
    static func createDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd")
        return dateFormatter.string(from: date)
    }
    
    static func createTimeString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("h:mm a")
        return dateFormatter.string(from: date)
    }
    
    static func sortPosts(posts: [Post]) -> [Post] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMMd h:mm a"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        
        var sorted = posts.sorted(by: { (post1, post2) in
            let dateStr1 = post1.date.replacingOccurrences(of: "\n", with: " ")
            let dateStr2 = post2.date.replacingOccurrences(of: "\n", with: " ")
            let date1 = dateFormatter.date(from: dateStr1)
            let date2 = dateFormatter.date(from: dateStr2)
            return date1! < date2!
        })
        
        for post in sorted {
            let date = dateFormatter.date(from: post.date.replacingOccurrences(of: "\n", with: " "))!
            let now = Date()
            
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: date)
            dateComponents.year = 2018
            let fdate = calendar.date(from: dateComponents)!
            
            if fdate.timeIntervalSince1970 < now.timeIntervalSince1970 {
                sorted.remove(at: sorted.index(where: { i in
                    return post.postId == i.postId
                })!)
            }
        }
        return sorted
    }
    
}
