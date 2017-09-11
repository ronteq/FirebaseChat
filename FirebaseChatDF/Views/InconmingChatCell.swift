//
//  ChatCell.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation
import UIKit

class InconmingChatCell: UICollectionViewCell{
    
    fileprivate let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        return view
    }()
    
    let messageText: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.darkGray
        tv.isUserInteractionEnabled = false
        return tv
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}

extension InconmingChatCell{
    
    fileprivate func setupViews(){
        setupBubbleView()
        setupMessageLabel()
    }
    
    fileprivate func setupBubbleView(){
        addSubview(bubbleView)
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: frame.width / 2)
        
        bubbleWidthAnchor.isActive = true
    }
    
    fileprivate func setupMessageLabel(){
        bubbleView.addSubview(messageText)
        
        messageText.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageText.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8).isActive = true
        messageText.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
        messageText.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }
    
}
