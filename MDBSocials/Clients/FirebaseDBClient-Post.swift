//
//  FirebaseDBClient-Post.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/27/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import FirebaseDatabase
import PromiseKit
import FirebaseStorage
import SwiftyJSON

extension FirebaseDBClient {
    
    static func updatePost(withBlock: @escaping (Post) -> ()) {
        let ref = Database.database().reference().child("Posts")
        ref.observe(.childChanged, with: { (snapshot) in
            let json = JSON(snapshot.value)
            if let result = json.dictionaryObject {
                if let post = Post(JSON: result) {
                    withBlock(post)
                }
            }
        })
    }
    
}
