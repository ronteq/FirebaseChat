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
    
    init(toId: String, fromId: String, message: String) {
        self.toId = toId
        self.fromId = fromId
        self.message = message
        self.timestamp = Date().timeIntervalSince1970
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
