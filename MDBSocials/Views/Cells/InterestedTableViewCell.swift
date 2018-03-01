//
//  InterestedTableViewCell.swift
//  MDBSocials
//
//  Created by Tiger Chen on 3/1/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit
import ChameleonFramework

class InterestedTableViewCell: UITableViewCell {
    
    var userImageView: UIImageView!
    var usernameLabel: UILabel!
    var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView = UIImageView(frame: CGRect(x: 10, y: 5, width: 60, height: 60))
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 30
        addSubview(userImageView)
        
        usernameLabel = UILabel(frame: CGRect(x: 90, y: 5, width: 200, height: 25))
        usernameLabel.textColor = Constants.lightBlueColor
        usernameLabel.font = UIFont.systemFont(ofSize: 18)
        addSubview(usernameLabel)
        
        nameLabel = UILabel(frame: CGRect(x: 90, y: usernameLabel.frame.maxY, width: 200, height: 25))
        nameLabel.textColor = .flatGray()
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        addSubview(nameLabel)
    }

}
