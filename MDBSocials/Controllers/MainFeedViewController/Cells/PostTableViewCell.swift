//
//  PostTableViewCell.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/20/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    var eventLabel: UILabel!
    var hostLabel: UILabel!
    var dateLabel: UILabel!
    var interestLabel: UILabel!
    var eventImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        setupLabels()
    }
    
    // MARK: Creation functions
    
    func setupLabels() {
        eventLabel = UILabel(frame: CGRect(x: 10, y: 5, width: contentView.frame.width - 120, height: 30))
        eventLabel.font = UIFont.systemFont(ofSize: 25)
        addSubview(eventLabel)
        
        hostLabel = UILabel(frame: CGRect(x: 10, y: eventLabel.frame.maxY, width: contentView.frame.width - 10, height: 20))
        addSubview(hostLabel)
        
        dateLabel = UILabel(frame: CGRect(x: contentView.frame.width - 110, y: 5, width: 100, height: 50))
        dateLabel.numberOfLines = 2
        dateLabel.textAlignment = .right
        addSubview(dateLabel)
        
        // interestLabel goes on top of image view
        setupImageView()
        
        interestLabel = UILabel(frame: CGRect(x: 15, y: contentView.frame.height - 40, width: 120, height: 25))
        interestLabel.textColor = .white
        interestLabel.textAlignment = .center
        interestLabel.layer.cornerRadius = 5
        interestLabel.clipsToBounds = true
        interestLabel.backgroundColor = Constants.lightBlueColor
        addSubview(interestLabel)
    }
    
    func setupImageView() {
        eventImageView = UIImageView(frame: CGRect(x: 10, y: hostLabel.frame.maxY + 5, width: contentView.frame.width - 20, height: contentView.frame.height - hostLabel.frame.maxY - 15))
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.clipsToBounds = true
        addSubview(eventImageView)
    }

}
