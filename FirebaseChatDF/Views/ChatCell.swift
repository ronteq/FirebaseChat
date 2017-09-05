//
//  ChatCell.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation
import UIKit

class ChatCell: UICollectionViewCell{
    
    let messageText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Helvetica-Light", size: 16)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}

extension ChatCell{
    
    fileprivate func setupViews(){
        addSubview(messageText)
        
        messageText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        messageText.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
