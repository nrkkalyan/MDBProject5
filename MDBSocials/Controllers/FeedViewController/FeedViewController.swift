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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
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
    
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "MDBSocials"
        let backItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(logoutButtonTapped))
//        backItem.title = ""
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
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "postCell")
        view.addSubview(tableView)
    }

}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(String(indexPath.item) + " selected")
    }
    
}
