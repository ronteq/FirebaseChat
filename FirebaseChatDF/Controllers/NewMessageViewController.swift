//
//  NewMessageViewController.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import UIKit

class NewMessageViewController: UIViewController {

    var homeController: HomeViewController?
    
}

//MARK: Life cycle

extension NewMessageViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
}

//MARK: Initial setup

extension NewMessageViewController{
    
    fileprivate func initialSetup(){
        view.backgroundColor = UIColor.white
        navigationItem.title = "All users"
        addCancelBarButtonItem()
    }
    
    fileprivate func addCancelBarButtonItem(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NewMessageViewController.cancelBarBtnTapped))
    }
    
}

//MARK: Handling methods

extension NewMessageViewController{
    
    @objc
    fileprivate func cancelBarBtnTapped(){
        dismiss(animated: true) { 
            self.homeController?.pushToChat()
        }
    }

}
