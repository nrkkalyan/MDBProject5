//
//  FeedViewController.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/19/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON

class MainFeedViewController: UIViewController {

    var createEventButton: UIBarButtonItem!
    var tableView: UITableView!
    
    var posts: [Post] = []
    var showPost: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Main Feed"
        setupNavigationBar()
        setupTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(unhideNavigationBar), name: NSNotification.Name(rawValue: "unhideNBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideNavigationBar), name: NSNotification.Name(rawValue: "hideNBar"), object: nil)
        
        firstly {
            return RESTAPIClient.fetchPosts()
        }.done { posts in
            let group = DispatchGroup()
            for post in posts {
                group.enter()
                firstly {
                    return Utils.getImage(withUrl: post.imageUrl)
                }.done { image in
                    post.image = image
                    group.leave()
                }
            }
            group.notify(queue: .main, execute: {
                self.posts = Utils.sortPosts(posts: posts)
                self.tableView.reloadData()
            })
        }
        
        FirebaseDBClient.updatePost(withBlock: { (update) in
            if let postIndex = self.posts.index(where: { (post) in
                return post.postId == update.postId
            }) {
                self.posts[postIndex] = update
                firstly {
                    return Utils.getImage(withUrl: self.posts[postIndex].imageUrl)
                }.done { image in
                    self.posts[postIndex].image = image
                    self.tableView.reloadData()
                }
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewPost), name: NSNotification.Name(rawValue: "newPost"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupNavigationBar()
    }
    
    @objc func addNewPost(not: Notification) {
        let newPost = not.userInfo as! [String : Any]
        let json = JSON(newPost)
        if let result = json.dictionaryObject {
            if let post = Post(JSON: result) {
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
    
    @objc func unhideNavigationBar() {
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc func hideNavigationBar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { () -> Void in
            self.navigationController?.isNavigationBarHidden = true
        })
    }
    
    @objc func createEventButtonTapped() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createEvent") as? CreateEventViewController
        {
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: true, completion: nil)
            
        }
    }
    
    @objc func logoutButtonTapped() {
        UserAuthHelper.logOut(withBlock: { () in
            log.info("Logging out.")
            self.navigationController?.popViewController(animated: true)
        })
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
    
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = Constants.lightBlueColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.isNavigationBarHidden = false
//        navigationController?.navigationItem.title = "MDBSocials"
        navigationController?.viewControllers[1].navigationItem.title = "MDBSocials"
        let backItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(logoutButtonTapped))
//        navigationController?.navigationItem.leftBarButtonItem = backItem
        navigationController?.viewControllers[1].navigationItem.leftBarButtonItem = backItem
        
        let eventButton = UIButton(type: .custom)
        let attrStr = NSAttributedString(string: "+", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 40)])
        eventButton.setAttributedTitle(attrStr, for: .normal)
        eventButton.addTarget(self, action: #selector(createEventButtonTapped), for: .touchUpInside)
        createEventButton = UIBarButtonItem(customView: eventButton)
//        navigationController?.navigationItem.rightBarButtonItem = createEventButton
        navigationController?.viewControllers[1].navigationItem.rightBarButtonItem = createEventButton
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "postCell")
        view.addSubview(tableView)
    }

}

extension MainFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        showPost = posts[indexPath.item]
        performSegue(withIdentifier: "toEventDetails", sender: self)
    }
    
}
