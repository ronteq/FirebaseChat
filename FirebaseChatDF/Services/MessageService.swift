//
//  MessageService.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct MessageService{
    
    func sendMessage(toId: String, message: String){
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        let databaseRef = Database.database().reference()
        let messagesRef = databaseRef.child(FirebasePaths.messages).childByAutoId()
        
        let message = Message(toId: toId, fromId: fromId, message: message)
        let messageInfo = message.convertToDictionary()
        
        messagesRef.setValue(messageInfo) { (error, reference) in
            self.createUserMessageAssociation(messageKey: reference.key, userId: fromId)
            self.createUserMessageAssociation(messageKey: reference.key, userId: toId)
        }
    }
    
    func createUserMessageAssociation(messageKey: String, userId: String){
        let databaseRef = Database.database().reference()
        let userMessageRef = databaseRef.child(FirebasePaths.userMessages).child(userId)
        
        let messageInfo = [messageKey: true]
        
        userMessageRef.updateChildValues(messageInfo)
    }
    
    func observeMessages(){
        
    }
    
}
