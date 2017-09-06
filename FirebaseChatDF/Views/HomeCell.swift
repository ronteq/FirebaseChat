//
//  HomeCell.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/6/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation

import UIKit

class HomeCell: UITableViewCell{
    
    fileprivate let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.darkGray
        label.font = UIFont(name: "Helvetica", size: 16)
        return label
    }()
    
    fileprivate let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.darkGray
        label.font = UIFont(name: "Helvetica-Light", size: 12)
        return label
    }()
    
    fileprivate let timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.darkGray
        label.font = UIFont(name: "Helvetica-Light", size: 12)
        return label
    }()
    
    let userService = UserService()
    
    var message: Message!{
        didSet{
            getUserFromId(message.toId) { (user) in
                self.fillUI(withUser: user)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension HomeCell{
    
    fileprivate func setupViews(){
        addSubview(nameLabel)
        addSubview(messageLabel)
        addSubview(timestampLabel)
        
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        timestampLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        timestampLabel.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor).isActive = true
    }
    
}

extension HomeCell{
    
    fileprivate func getUserFromId(_ id: String, completion: @escaping(_ user: User)-> Void){
        userService.getUserFromId(id) { (user) in
            completion(user)
        }
    }
    
    fileprivate func fillUI(withUser user: User){
        nameLabel.text = user.name
        messageLabel.text = message.message
        timestampLabel.text = message.formatDate()
    }
    
}
