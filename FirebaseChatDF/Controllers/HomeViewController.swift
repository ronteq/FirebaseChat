//
//  HomeViewController.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    fileprivate lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(HomeCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    let userService = UserService()
    let messageService = MessageService()
    
    var messages = [Message]()
    
    deinit {
        print("HomeViewController deleted")
        messageService.removeObservers()
    }

}

//MARK: Life cycle

extension HomeViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeForAddedMessages()
    }
    
}

//MARK: Initial setup

extension HomeViewController{
    
    fileprivate func initialSetup(){
        navigationItem.title = "Home"
        view.backgroundColor = UIColor.white
        addBarButtonsItems()
    }
    
    fileprivate func addBarButtonsItems(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(HomeViewController.logoutBarBtnTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(HomeViewController.newBarBtnTapped))
    }
    
    fileprivate func setupTableView(){
        view.addSubview(tableView)
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}

//MARK: Handling methods

extension HomeViewController{
    
    @objc
    fileprivate func logoutBarBtnTapped(){
        userService.logout()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    fileprivate func newBarBtnTapped(){
        let newMessageController = NewMessageViewController()
        newMessageController.homeController = self
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }
    
}

//MARK: Private methods

extension HomeViewController{
    
    func pushToChat(user: User){
        let chatController = ChatViewController()
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    fileprivate func observeForAddedMessages(){
        messageService.observeAddedMessages { (messages) in
            self.messages.removeAll()
            self.messages = messages
            
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func getUserFromId(_ id: String, completion: @escaping(_ user: User)-> Void){
        userService.getUserFromId(id) { (user) in
            completion(user)
        }
    }
    
}

//MARK: UITableViewDelegate

extension HomeViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toId = messages[indexPath.row].toId
        getUserFromId(toId) { (user) in
            self.pushToChat(user: user)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

//MARK: UITableViewDataSource

extension HomeViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeCell
        
        cell.message = messages[indexPath.row]
        
        return cell
    }
    
}
