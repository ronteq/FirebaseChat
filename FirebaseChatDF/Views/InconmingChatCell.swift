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
        
        bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        
        addSubview(bubbleView)
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: frame.width / 2)
        
        bubbleWidthAnchor.isActive = true
    }
    
    override func setupMessageLabel() {
        super.setupMessageLabel()
        
        messageText.textColor = UIColor.darkGray
    }
    
}
