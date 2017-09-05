//
//  Message.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation

class Message{
    
    var toId: String
    var fromId: String
    var message: String
    var timestamp: Double
    
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
        
        self.init(toId: toId, fromId: fromId, message: message, timestamp: timestamp)
    }
    
    func convertToDictionary()-> [String: Any]{
        let messageInfo: [String: Any] = [
            JSONKeys.toId: toId,
            JSONKeys.fromId: fromId,
            JSONKeys.message: message,
            JSONKeys.timestamp: timestamp
        ]
        
        return messageInfo
    }
    
}

extension Message{
    
    struct JSONKeys{
        static let toId = "toId"
        static let fromId = "fromId"
        static let message = "message"
        static let timestamp = "timestamp"
    }
    
}
