//
//  UserChatCell.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation
import UIKit

class UserChatCell: ChatCell{
        
    override func setupBubbleView(){
        addSubview(bubbleView)
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: frame.width / 2)
        
        bubbleWidthAnchor.isActive = true
    }
    
}
