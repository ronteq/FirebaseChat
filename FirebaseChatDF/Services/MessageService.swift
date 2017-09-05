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
    
    let databaseRef = Database.database().reference()
    
    func sendMessage(toId: String, message: String){
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        let messagesRef = databaseRef.child(FirebasePaths.messages).childByAutoId()
        
        let message = Message(toId: toId, fromId: fromId, message: message, timestamp: nil)
        let messageInfo = message.convertToDictionary()
        
        messagesRef.setValue(messageInfo) { (error, reference) in
            self.createUserMessageAssociation(messageKey: reference.key, userId: fromId)
            self.createUserMessageAssociation(messageKey: reference.key, userId: toId)
        }
    }
    
    func createUserMessageAssociation(messageKey: String, userId: String){
        
        let userMessageRef = databaseRef.child(FirebasePaths.userMessages).child(userId)
        
        let messageInfo = [messageKey: true]
        
        userMessageRef.updateChildValues(messageInfo)
    }
    
    func observeMessages(toId: String, completion: @escaping(_ messages: [Message])->Void){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userMessageRef = databaseRef.child(FirebasePaths.userMessages).child(uid)
        
        userMessageRef.observe(.childAdded, with: {(snapshot) in
            
            let messageKey = snapshot.key
            self.getDetailMessage(messageKey: messageKey, toId: toId, completion: { (messages) in
                completion(messages)
            })
            
        })
    }
    
    func getDetailMessage(messageKey: String, toId: String, completion: @escaping(_ messages: [Message])-> Void){
        
        var messages = [Message]()
        
        let messageRef = databaseRef.child(FirebasePaths.messages).child(messageKey)
        
        messageRef.observe(.value, with: {(snapshot) in
        
            guard let messageDictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let message = Message(withDictionary: messageDictionary) else { return }
            
            if message.toId == toId || message.fromId == toId{
                messages.append(message)
            }
        
            completion(messages)
        })
    }
    
    func removeObservers(){
        databaseRef.removeAllObservers()
    }
    
}
