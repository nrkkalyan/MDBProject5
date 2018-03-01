//
//  InterestedDetailView.swift
//  MDBSocials
//
//  Created by Tiger Chen on 3/1/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit
import ChameleonFramework

class InterestedDetailView: UIView {
    
    var label: UILabel!
    var tableView: UITableView!
    var users: [User]!

    init(frame: CGRect, users: [User]) {
        super.init(frame: frame)
        
        self.users = users
        layer.cornerRadius = 3
        clipsToBounds = true
        backgroundColor = .white
        setupLabel()
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Creation functions
    
    func setupLabel() {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 40))
        label.text = "Interested Users:"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25)
        label.textColor = .white
        label.backgroundColor = Constants.lightBlueColor
        addSubview(label)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: frame.minX, y: label.frame.maxY, width: frame.width, height: frame.height - label.frame.height))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(InterestedTableViewCell.self, forCellReuseIdentifier: "interestedCell")
        addSubview(tableView)
    }

}

extension InterestedDetailView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "interestedCell", for: indexPath) as! InterestedTableViewCell
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.awakeFromNib()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! InterestedTableViewCell
        let user = users[indexPath.row]
        
        cell.nameLabel.text = user.name
        cell.usernameLabel.text = user.username
        cell.userImageView.image = user.image
    }
}
