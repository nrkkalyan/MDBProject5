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
    
    static let lightBlue = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0)
    
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
    
}
