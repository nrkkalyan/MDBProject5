//
//  UserFeedViewController.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/28/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit
import PromiseKit
import FirebaseAuth
import SwiftyJSON

class UserFeedViewController: UIViewController {

    var tableView: UITableView!
    
    var posts: [Post] = []
    var showPost: Post!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tabBarController?.viewControllers![1].title = "User Feed"
        setupTableView()
        
        // get current user events
        
        if let uid = Auth.auth().currentUser?.uid {
            self.uid = uid
            firstly {
                return User.getCurrentUser(withId: uid)
            }.done { user in
                var events = [String]()
                log.info(user.interested)
                events.append(contentsOf: user.created ?? [])
                events.append(contentsOf: user.interested ?? [])
                self.fetchPosts(events: events)
            }
            
        }
        
        FirebaseDBClient.updatePost(withBlock: { (update) in
            if let postIndex = self.posts.index(where: { (post) in
                return post.postId == update.postId
            }) {
                if !self.posts[postIndex].interested.contains(update.postId) {
                    self.posts.remove(at: postIndex)
                    self.tableView.reloadData()
                } else {
                    self.posts[postIndex] = update
                    firstly {
                        return Utils.getImage(withUrl: update.imageUrl)
                    }.done { image in
                        update.image = image
                        self.tableView.reloadData()
                    }
                }
            } else if update.interested.contains(self.uid) {
                self.posts.append(update)
                firstly {
                    return Utils.getImage(withUrl: update.imageUrl)
                }.done { image in
                    update.image = image
                        self.tableView.reloadData()
                }
            }
            self.posts = Utils.sortPosts(posts: self.posts)
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewPost), name: NSNotification.Name(rawValue: "newPost"), object: nil)
    }
    
    @objc func addNewPost(not: Notification) {
        let newPost = not.userInfo as! [String : Any]
        let json = JSON(newPost)
        if let result = json.dictionaryObject {
            if let post = Post(JSON: result) {
                if post.hostId == uid {
                    self.posts.append(post)
                    firstly {
                        return Utils.getImage(withUrl: post.imageUrl)
                    }.done { image in
                        post.image = image
                        self.posts = Utils.sortPosts(posts: self.posts)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is EventDetailViewController {
            let vc = segue.destination as! EventDetailViewController
            vc.post = showPost
            
            if let index = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: index, animated: false)
            }
        }
    }
    
    func fetchPosts(events: [String]) {
        let group = DispatchGroup()
        log.info(events.count)
        for event in events {
            group.enter()
            firstly {
                return RESTAPIClient.fetchPost(pid: event)
            }.done { post in
                self.posts.append(post)
                firstly {
                    return Utils.getImage(withUrl: post.imageUrl)
                }.done { image in
                    post.image = image
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main, execute: {
            self.tableView.reloadData()
            self.posts = Utils.sortPosts(posts: self.posts)
        })
    }
    
    // MARK: Creation functions
    
    func setupTableView() {
        tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "postCell")
        view.addSubview(tableView)
    }

}

extension UserFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count != 0 ? posts.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.awakeFromNib()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! PostTableViewCell
        if posts.count > indexPath.item {
            let post = posts[indexPath.item]
            cell.eventLabel.text = post.name
            cell.dateLabel.text = post.date
            cell.hostLabel.text = post.host
            cell.interestLabel.text = "Interested: \(post.interested.count)"
            cell.eventImageView.image = post.image
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.info("Post " + String(indexPath.item) + " selected in feed")
        if indexPath.item < posts.count {
            showPost = posts[indexPath.item]
            performSegue(withIdentifier: "toEventDetails", sender: self)
        }
    }
    
}
