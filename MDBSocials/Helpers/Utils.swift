//
//  Utils.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/22/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
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
        var sorted = posts.sorted(by: { (post1, post2) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMMd h:mm a"
            
            let dateStr1 = post1.date.replacingOccurrences(of: "\n", with: " ")
            let dateStr2 = post2.date.replacingOccurrences(of: "\n", with: " ")
            let date1 = dateFormatter.date(from: dateStr1)
            let date2 = dateFormatter.date(from: dateStr2)
            return date1! < date2!
        })
        return sorted
    }
    
}
