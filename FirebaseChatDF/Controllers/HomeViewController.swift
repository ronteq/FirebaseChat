//
//  HomeViewController.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    let userService = UserService()

}

//MARK: Life cycle

extension HomeViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
}

//MARK: Initial setup

extension HomeViewController{
    
    fileprivate func initialSetup(){
        navigationItem.hidesBackButton = true
        navigationItem.title = "Home"
        view.backgroundColor = UIColor.white
        addBarButtonsItems()
    }
    
    fileprivate func addBarButtonsItems(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(HomeViewController.logoutBarBtnTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(HomeViewController.newBarBtnTapped))
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
    
    func pushToChat(){
        
    }
    
}
