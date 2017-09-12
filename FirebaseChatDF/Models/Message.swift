//
//  Message.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation

class Message{
    
    var messageId: String = ""
    var toId: String
    var fromId: String
    var message: String = ""
    var timestamp: Double
    
    var imageUrl: String?
    
    //Fetching messages
    init(messageId: String, toId: String, fromId: String, message: String, timestamp: Double?, imageUrl: String?) {
        self.messageId = messageId
        self.toId = toId
        self.fromId = fromId
        self.message = message
        self.imageUrl = imageUrl
        
        if let timestamp = timestamp{
            self.timestamp = timestamp
        }else{
            self.timestamp = Date().timeIntervalSince1970
        }
    }
    
    //Sending a text
    init(toId: String, fromId: String, message: String, timestamp: Double?) {
        self.toId = toId
        self.fromId = fromId
        self.message = message
        
        if let timestamp = timestamp{
            self.timestamp = timestamp
        }else{
            self.timestamp = Date().timeIntervalSince1970
        }
    }
    
    convenience init?(withDictionary dictionary: [String: AnyObject]){
        guard let toId = dictionary[JSONKeys.toId] as? String,
            let fromId = dictionary[JSONKeys.fromId] as? String,
            let message = dictionary[JSONKeys.message] as? String,
            let timestamp = dictionary[JSONKeys.timestamp] as? Double else { return nil }
        
        var imageUrl: String?
        
        if let url = dictionary[JSONKeys.imageUrl] as? String{
            imageUrl = url
        }
        
        if let messageId = dictionary[JSONKeys.messageId] as? String{
            self.init(messageId: messageId, toId: toId, fromId: fromId, message: message, timestamp: timestamp, imageUrl: imageUrl)
        }else{
            self.init(toId: toId, fromId: fromId, message: message, timestamp: timestamp)
        }
        
    }
    
    func convertToDictionary()-> [String: Any]{
        var messageInfo: [String: Any] = [
            JSONKeys.toId: toId,
            JSONKeys.fromId: fromId,
            JSONKeys.message: message,
            JSONKeys.timestamp: timestamp
        ]
        
        if let imageUrl = imageUrl{
            messageInfo[JSONKeys.imageUrl] = imageUrl
        }
        
        return messageInfo
    }
    
    func formatDate()-> String{
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        return dateFormatter.string(from: date)
    }
    
}

extension Message{
    
    struct JSONKeys{
        static let messageId = "messageId"
        static let toId = "toId"
        static let fromId = "fromId"
        static let message = "message"
        static let imageUrl = "imageUrl"
        static let timestamp = "timestamp"
    }
    
}
