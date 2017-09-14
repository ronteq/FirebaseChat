//
//  NewMessageViewController.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import UIKit

class NewMessageViewController: UIViewController {

    fileprivate lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    var users = [User]()
    
    var homeController: HomeViewController?
    let userService = UserService()
}

//MARK: Life cycle

extension NewMessageViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        fetchUsers()
    }
    
}

//MARK: Initial setup

extension NewMessageViewController{
    
    fileprivate func initialSetup(){
        view.backgroundColor = UIColor.white
        navigationItem.title = "Users"
        addCancelBarButtonItem()
        setupTableView()
    }
    
    fileprivate func addCancelBarButtonItem(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NewMessageViewController.cancelBarBtnTapped))
    }
    
    fileprivate func setupTableView(){
        view.addSubview(tableView)
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}

//MARK: Private methods

extension NewMessageViewController{
    
    fileprivate func fetchUsers(){
        userService.fetchAllUsers { (users) in
            self.users = users
            
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    
}

//MARK: Handling methods

extension NewMessageViewController{
    
    @objc
    fileprivate func cancelBarBtnTapped(){
        dismiss(animated: true, completion: nil)
    }

}

//MARK: UITableViewDataSource

extension NewMessageViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = users[indexPath.row].name
        
        return cell
    }
    
}

//MARK: UITableViewDelegate

extension NewMessageViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.homeController?.pushToChat(user: self.users[indexPath.row])
        }
    }
    
}




