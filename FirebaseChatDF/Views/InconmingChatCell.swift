//
//  ChatCell.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation
import UIKit

class InconmingChatCell: ChatCell{
    
    override func setupBubbleView(){
        
        addSubview(bubbleView)
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: frame.width / 2)
        
        bubbleWidthAnchor.isActive = true
        
        bubbleView.addSubview(bubbleImageView)
        
        bubbleImageView.image = #imageLiteral(resourceName: "leftBubble").resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
        bubbleImageView.tintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        
        bubbleImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor).isActive = true
        bubbleImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        bubbleImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
        bubbleImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
    }
    
    override func setupMessageLabel() {
        super.setupMessageLabel()
        
        messageText.textColor = UIColor.darkGray
        
        messageText.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12).isActive = true
        messageText.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
    }
    
}
