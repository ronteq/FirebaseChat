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
    var videoUrl: String?
    var mediaWidth: Double?
    var mediaHeight: Double?
    
    //Fetching messages
    init(messageId: String, toId: String, fromId: String, message: String, timestamp: Double?, imageUrl: String?, videoUrl: String?, mediaWidth: Double?, mediaHeight: Double?) {
        self.messageId = messageId
        self.toId = toId
        self.fromId = fromId
        self.message = message
        
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.mediaWidth = mediaWidth
        self.mediaHeight = mediaHeight
        
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
        var videoUrl: String?
        var mediaWidth: Double?
        var mediaHeight: Double?
        
        if let url = dictionary[JSONKeys.imageUrl] as? String{
            imageUrl = url
        }
        
        if let url = dictionary[JSONKeys.videoUrl] as? String{
            videoUrl = url
        }
        
        if let width = dictionary[JSONKeys.mediaWidth] as? Double,
            let height = dictionary[JSONKeys.mediaHeight] as? Double{
            
            mediaWidth = width
            mediaHeight = height
        }
        
        if let messageId = dictionary[JSONKeys.messageId] as? String{
            self.init(messageId: messageId, toId: toId, fromId: fromId, message: message, timestamp: timestamp, imageUrl: imageUrl, videoUrl: videoUrl, mediaWidth: mediaWidth, mediaHeight: mediaHeight)
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
        
        if let videoUrl = videoUrl{
            messageInfo[JSONKeys.videoUrl] = videoUrl
        }
        
        if let mediaWidth = mediaWidth,
            let mediaHeight = mediaHeight{
            messageInfo[JSONKeys.mediaWidth] = mediaWidth
            messageInfo[JSONKeys.mediaHeight] = mediaHeight
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
        static let videoUrl = "videoUrl"
        static let mediaWidth = "mediaWidth"
        static let mediaHeight = "mediaHeight"
        static let timestamp = "timestamp"
    }
    
}
