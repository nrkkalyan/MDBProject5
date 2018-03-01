//
//  EventDetailViewController.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/19/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit
import FirebaseAuth
import PromiseKit

class EventDetailViewController: UIViewController {

    var nameLabel: UILabel!
    var hostLabel: UILabel!
    var dateLabel: UILabel!
    var eventImageView: UIImageView!
    var interestButton: UIButton!
    var interestLabel: UIButton!
    var descriptionLabel: UILabel!
    var scrollView: UIScrollView!
    var interestedDetailView: InterestedDetailView!
    var modalView: AKModalView!
    
    var post: Post!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabels()
        setupScrollView()
        
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid
        }
        interestButtonChecked()
    }
    
    func interestButtonChecked() {
        if uid.elementsEqual(post.hostId) || post.interested.contains(uid) {
            interestButton.setTitle("Interested", for: .normal)
            interestButton.backgroundColor = Constants.lightBlueColor
            interestButton.layer.borderWidth = 0
            interestButton.setTitleColor(.white, for: .normal)
        } else {
            interestButton.setTitle("Interested?", for: .normal)
            interestButton.backgroundColor = .white
            interestButton.layer.borderWidth = 1
            interestButton.setTitleColor(.black, for: .normal)
        }
    }
    
    func fetchUsers(uids: [String]) -> Promise<[User]> {
        return Promise { seal in
            let group = DispatchGroup()
            var users: [User] = []
            for uid in uids {
                group.enter()
                firstly {
                    return FirebaseDBClient.fetchUser(id: uid)
                }.done { user in
                    users.append(user)
                    user.getEventImage(withBlock: { () in
                        group.leave()
                    })
                }
            }
            group.notify(queue: DispatchQueue.main, execute: { () in
                seal.fulfill(users)
            })
        }
    }
    
    @objc func interestButtonTapped() {
        
        // host has to be interested!
        if !uid.elementsEqual(post.hostId) {
            FirebaseDBClient.updateInterestedCounter(uid: uid, pid: post.postId, withBlock: { (interested) in
                self.post.interested = interested
//                self.interestLabel.text = "Interested: \(self.post.interested.count)"
                self.interestLabel.setTitle("Interested: \(self.post.interested.count)", for: .normal)
                self.interestButtonChecked()
            })
        }
    }
    
    @objc func showInterested() {
        let navBarHeight = navigationController?.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        firstly {
            return fetchUsers(uids: post.interested)
        }.done { users in
            self.interestedDetailView = InterestedDetailView(frame: CGRect(x: 0, y: 70, width: self.view.frame.width - 60, height: self.view.frame.height - 75 - (110 - navBarHeight! - statusBarHeight)), users: users)
            self.modalView = AKModalView(view: self.interestedDetailView)
            self.modalView.dismissAnimation = .FadeOut
            self.navigationController?.view.addSubview(self.modalView)
            self.modalView.show()
        }
    }
    
    // MARK: Creation functions
    
    func setupLabels() {
        nameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.width - 20, height: 50))
        nameLabel.font = UIFont.systemFont(ofSize: 50)
        nameLabel.text = post.name
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.textAlignment = .center
        
        hostLabel = UILabel(frame: CGRect(x: 10, y: nameLabel.frame.maxY, width: view.frame.width - 20, height: 20))
        hostLabel.text = "Host: \(post.host!)"
        hostLabel.textAlignment = .center
        
        dateLabel = UILabel(frame: CGRect(x: 10, y: hostLabel.frame.maxY, width: view.frame.width - 20, height: 20))
        let date = post.date.split(separator: "\n")
        dateLabel.text = "\(date[1]) \(date[0])"
        dateLabel.textAlignment = .center
        
        interestLabel = UIButton(frame: CGRect(x: 10, y: dateLabel.frame.maxY + 5, width: 150, height: 30))
//        interestLabel.text = "Interested: \(post.interested.count)"
//        interestLabel.textColor = Constants.lightBlueColor
        interestLabel.contentHorizontalAlignment = .left
        interestLabel.setTitle("Interested: \(post.interested.count)", for: .normal)
        interestLabel.setTitleColor(Constants.lightBlueColor, for: .normal)
        interestLabel.addTarget(self, action: #selector(showInterested), for: .touchUpInside)
        
        
        // places descriptionLabel below image view
        setupImageView()
        
        descriptionLabel = UILabel(frame: CGRect(x: 10, y: eventImageView.frame.maxY + 5, width: view.frame.width - 20, height: 50))
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.text = "Description:\n\(post.description!)"
        descriptionLabel.sizeToFit()
    }
    
    func setupImageView() {
        setupButtons()
        
        let image = post.image
        let width = Double((image?.size.width)!)
        let height = Double((image?.size.height)!)
        let aspect = width/height
        let newHeight = Double(view.frame.width - 20)/aspect
        
        eventImageView = UIImageView(frame: CGRect(x: 10, y: interestButton.frame.maxY + 5, width: view.frame.width - 20, height: CGFloat(newHeight)))
        eventImageView.image = post.image
    }
    
    func setupButtons() {
        interestButton = UIButton(frame: CGRect(x: view.frame.width - 110, y: dateLabel.frame.maxY + 5, width: 100, height: 30))
        interestButton.setTitle("Interested?", for: .normal)
        interestButton.setTitleColor(.black, for: .normal)
        interestButton.layer.cornerRadius = 5
        interestButton.layer.borderWidth = 1
        interestButton.layer.borderColor = UIColor.black.cgColor
        interestButton.clipsToBounds = true
        interestButton.addTarget(self, action: #selector(interestButtonTapped), for: .touchUpInside)
    }
    
    func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(hostLabel)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(interestLabel)
        scrollView.addSubview(interestButton)
        scrollView.addSubview(eventImageView)
        scrollView.addSubview(descriptionLabel)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: descriptionLabel.frame.maxY + 5)
        
        view.addSubview(scrollView)
    }
    
}
