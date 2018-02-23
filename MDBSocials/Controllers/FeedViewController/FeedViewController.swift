//
//  FeedViewController.swift
//  MDBSocials
//
//  Created by Tiger Chen on 2/19/18.
//  Copyright © 2018 Tiger Chen. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

    var createEventButton: UIBarButtonItem!
    var tableView: UITableView!
    
    var posts: [Post] = []
    var showPost: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()

        setupNavigationBar()
        setupTableView()
        
        FirebaseAPIClient.fetchPosts(withBlock: { (post) in
            self.posts.insert(post, at: 0)
            post.getEventImage(withBlock: { () in
                self.tableView.reloadData()
            })
            
            activityIndicator.stopAnimating()
        })
        
        FirebaseAPIClient.updatePost(withBlock: { (update) in
            if let postIndex = self.posts.index(where: { (post) in
                return post.postId == update.postId
            }) {
                print(postIndex)
                self.posts[postIndex] = update
                self.posts[postIndex].getEventImage(withBlock: { () in
                    self.tableView.reloadData()
                })
            }
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
        navigationController?.navigationBar.barTintColor = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "MDBSocials"
        let backItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(logoutButtonTapped))
        navigationItem.leftBarButtonItem = backItem
        
        let eventButton = UIButton(type: .custom)
        let attrStr = NSAttributedString(string: "+", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 40)])
        eventButton.setAttributedTitle(attrStr, for: .normal)
        eventButton.addTarget(self, action: #selector(createEventButtonTapped), for: .touchUpInside)
        createEventButton = UIBarButtonItem(customView: eventButton)
        navigationItem.rightBarButtonItem = createEventButton
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

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        print(String(indexPath.item) + " selected")
        showPost = posts[indexPath.item]
        performSegue(withIdentifier: "toEventDetails", sender: self)
    }
    
}
