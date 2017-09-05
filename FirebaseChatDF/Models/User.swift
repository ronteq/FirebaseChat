//
//  User.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation

class User{
    
    var id: String
    var name: String
    var email: String

    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    convenience init?(withDictionary dictionary: [String: AnyObject]){
        guard let id = dictionary[JSONKeys.id] as? String,
            let name = dictionary[JSONKeys.name] as? String,
            let email = dictionary[JSONKeys.email] as? String else { return nil}
        
        self.init(id: id, name: name, email: email)
        
    }
}

extension User{
    fileprivate struct JSONKeys{
        static let id = "id"
        static let name = "name"
        static let email = "email"
    }
}
