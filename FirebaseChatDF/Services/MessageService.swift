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
import FirebaseStorage

struct MessageService{
    
    let databaseRef = Database.database().reference()
    
    func removeObservers(){
        databaseRef.removeAllObservers()
    }
    
    func isMessageFromCurrentUser(_ message: Message)-> Bool{
        guard let uid = Auth.auth().currentUser?.uid else { return true }
        return message.fromId == uid
    }
    
}

//MARK: Creating message

extension MessageService{
    
    func sendMessage(toId: String, message: String, imageUrl: String?, mediaWidth: Double?, mediaHeight: Double?, videoUrl: String?){
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        let messagesRef = databaseRef.child(FirebasePaths.messages).childByAutoId()
        
        let newMessage = Message(toId: toId, fromId: fromId, message: message, timestamp: nil)
        
        newMessage.imageUrl = imageUrl
        newMessage.videoUrl = videoUrl
        newMessage.mediaWidth = mediaWidth
        newMessage.mediaHeight = mediaHeight
        
        let messageInfo = newMessage.convertToDictionary()
        
        messagesRef.setValue(messageInfo) { (error, reference) in
            self.createUserMessageAssociation(messageKey: reference.key, userIdOne: fromId, userIdTwo: toId)
            self.createUserMessageAssociation(messageKey: reference.key, userIdOne: toId, userIdTwo: fromId)
            self.createLastMessageForUser(fromId: fromId, toId: toId, message: message, timestamp: newMessage.timestamp)
            self.createLastMessageForUser(fromId: toId, toId: fromId, message: message, timestamp: newMessage.timestamp)
            
        }
    }
    
    private func createUserMessageAssociation(messageKey: String, userIdOne: String, userIdTwo: String){
        
        let userMessageRef = databaseRef.child(FirebasePaths.userMessages).child(userIdOne).child(userIdTwo)
        
        let messageInfo = [messageKey: true]
        
        userMessageRef.updateChildValues(messageInfo)
    }
    
    private func createLastMessageForUser(fromId: String, toId: String, message: String, timestamp: Double){
        
        let lastUserMessageRef = databaseRef.child(FirebasePaths.lastUserMessage).child(fromId)
        
        let messageInfo: [String: Any] = [
            Message.JSONKeys.message: message,
            Message.JSONKeys.timestamp: timestamp
        ]
        
        let dataToSend: [String: Any] = [
            toId: messageInfo
        ]
        
        lastUserMessageRef.updateChildValues(dataToSend)
        
    }
    
}

//MARK: Deleting

extension MessageService{
    
    func deleteMessage(_ message: Message){
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        let toId = message.toId
        let dispatchGroup = DispatchGroup()
        
        let userMessagesRef = databaseRef.child(FirebasePaths.userMessages).child(fromId).child(toId)
        let lastUserMessageRef = databaseRef.child(FirebasePaths.lastUserMessage).child(fromId).child(toId)
        
        userMessagesRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            for child in snapshot.children{
                
                dispatchGroup.enter()
                
                guard let snap = child as? DataSnapshot else { return }
                
                let messagesRef = self.databaseRef.child(FirebasePaths.messages).child(snap.key)
                messagesRef.removeValue(completionBlock: { (error, reference) in
                    
                    dispatchGroup.leave()
                    
                })
                
            }
            
            dispatchGroup.notify(queue: .main, execute: { 
                userMessagesRef.removeValue()
            })
            
        })
        
        lastUserMessageRef.removeValue()
        
    }
    
}

//MARK: Sending MEDIA

extension MessageService{
    
    func uploadImageDataToFirebase(_ imageData: Data, completion: @escaping(_ imageUrl: String)-> Void){
        let imageId = NSUUID().uuidString + ".mov"
        let storageReference = Storage.storage().reference()
        let messageImagesReference = storageReference.child(FirebasePaths.messageImages).child(imageId)
        
        messageImagesReference.putData(imageData, metadata: nil) { (metadata, error) in
            
            if let error = error{
                print("Error while uploading image: \(error.localizedDescription)")
            }else{
                
                guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
                
                completion(imageUrl)
                
            }
            
        }
        
    }
    
    func uploadVideoUrlToFirebase(_ videoUrl: URL, completion: @escaping(_ videoUrl: String)-> Void){
        
        let videoId = NSUUID().uuidString
        let storageRef = Storage.storage().reference()
        let videoUrlRef = storageRef.child(FirebasePaths.messageVideos).child(videoId)
        
        videoUrlRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            
            if let error = error{
                print("Error while uploading video: \(error.localizedDescription)")
            }else{
                
                guard let stringVideoUrl = metadata?.downloadURL()?.absoluteString else { return }
                
                completion(stringVideoUrl)
                
            }
            
        }
        
    }
    
}

//MARK: Fetching messages for User

extension MessageService{
    
    func observeMessagesForUser(_ toId: String, completion: @escaping(_ messages: Message)->Void){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userMessageRef = databaseRef.child(FirebasePaths.userMessages).child(uid).child(toId)
        
        userMessageRef.queryLimited(toLast: 5).observe(.childAdded, with: {(snapshot) in
            
            let messageKey = snapshot.key
            self.getDetailMessageForUser(messageKey: messageKey, completion: { (message) in
                completion(message)
            })
            
        })
    }
    
    private func getDetailMessageForUser(messageKey: String, completion: @escaping(_ messages: Message)-> Void){
        
        let messageRef = databaseRef.child(FirebasePaths.messages).child(messageKey)
        
        messageRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            guard var messageDictionary = snapshot.value as? [String: AnyObject] else { return }
            
            messageDictionary[Message.JSONKeys.messageId] = messageKey as AnyObject
            
            guard let message = Message(withDictionary: messageDictionary) else { return }
            
            completion(message)
        })
    }
    
    func loadOldMessagesForUser(_ toId: String, lastMessageKey: String, completion: @escaping(_ messages: [Message])->Void){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var oldestMessages = [Message]()
        let dispatchGroup = DispatchGroup()
        
        let userMessageRef = databaseRef.child(FirebasePaths.userMessages).child(uid).child(toId)
        
        userMessageRef.queryOrderedByKey().queryEnding(atValue: lastMessageKey).queryLimited(toLast: 6).observeSingleEvent(of: .value, with: {(snapshot) in
            
            for child in snapshot.children{
                
                dispatchGroup.enter()
                
                guard let snap = child as? DataSnapshot else { return }
                let messageKey = snap.key
                
                self.getDetailMessageForUser(messageKey: messageKey, completion: { (message) in
                    
                    if message.messageId != lastMessageKey{
                        oldestMessages.append(message)
                    }
                    
                    dispatchGroup.leave()
                    
                })
                
            }
            
            dispatchGroup.notify(queue: .main, execute: { 
                completion(oldestMessages)
            })
            
        })
        
    }
    
}

//MARK: Fetching all messages

extension MessageService{
    
    func observeAddedMessages(completion: @escaping(_ messages: [Message])->Void){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let lastUserMessageRef = databaseRef.child(FirebasePaths.lastUserMessage).child(uid)
        
        var messages = [Message]()
        
        lastUserMessageRef.observe(.childAdded, with: {(snapshot) in
        
            guard var messageDictionary = snapshot.value as? [String: AnyObject] else { return }
            messageDictionary[Message.JSONKeys.fromId] = uid as AnyObject
            messageDictionary[Message.JSONKeys.toId] = snapshot.key as AnyObject
            
            guard let message = Message(withDictionary: messageDictionary) else { return }
            messages.append(message)
            
            messages.sort(by: { (message1, message2) -> Bool in
                let timestamp1 = Double(message1.timestamp)
                let timestamp2 = Double(message2.timestamp)
                return timestamp1 > timestamp2
            })
            
            completion(messages)
            
        })
        
    }
    
}
