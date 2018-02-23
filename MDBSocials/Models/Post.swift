//
//  Post.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/22/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class Post {
    
    var name: String!
    var description: String!
    var imageUrl: String!
    var host: String!
    var hostId: String!
    var postId: String!
    var date: String!
    var image: UIImage!
    var interested: [String]!
    
    init(id: String, postDict: [String:Any]?) {
        postId = id
        if postDict != nil {
            if let name = postDict!["name"] as? String {
                self.name = name
            }
            if let description = postDict!["description"] as? String {
                self.description = description
            }
            if let date = postDict!["date"] as? String {
                self.date = date
            }
            if let imageUrl = postDict!["imageUrl"] as? String {
                self.imageUrl = imageUrl
            }
            if let host = postDict!["host"] as? String {
                self.host = host
            }
            if let hostId = postDict!["hostId"] as? String {
                self.hostId = hostId
            }
            if let interested = postDict!["interested"] as? [String] {
                self.interested = interested
            }
        }
    }
    
    func getEventImage(withBlock: @escaping () -> ()) {
        let ref = Storage.storage().reference().child("/Event Images/\(postId!)")
        ref.getData(maxSize: 5 * 2048 * 2048, completion: { data, error in
            if let error = error {
                print(error)
            } else {
                self.image = UIImage(data: data!)
                withBlock()
            }
        })
    }
    
}
