//
//  UserService.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct UserService{
    
    
    
}

//MARK: Login - Signup

extension UserService{
    
    func login(email: String, password: String, completion: @escaping(_ errorMessage: String?)-> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error{
                completion(error.localizedDescription)
            }else{
                completion(nil)
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping(_ errorMessage: String?)-> Void){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error{
                completion(error.localizedDescription)
            }else{
                guard let email = user?.email else { return }
                guard let uid = user?.uid else { return }
                self.saveUserInformation(email, uid: uid)
            }
        }
    }
    
    func logout(){
        do{
            try Auth.auth().signOut()
        }catch{
            print("Error when logout")
        }
    }
    
    func isUserLogged()->Bool{
        if Auth.auth().currentUser != nil{
            return true
        }else{
            return false
        }
    }
    
    private func saveUserInformation(_ email: String, uid: String){
        let databaseRef = Database.database().reference()
        let userRef = databaseRef.child(FirebasePaths.users).child(uid)
        
        userRef.setValue(["email": email])
    }
    
}

//MARK: Fetch users

extension UserService{
    
    func fetchAllUsers(completion: @escaping(_ users: [User])-> Void){
        let databaseRef = Database.database().reference()
        let userRef = databaseRef.child(FirebasePaths.users)
        
        var users = [User]()
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //BUILDER
            for child in snapshot.children{
                guard let snap = child as? DataSnapshot else { return }
                guard var userInfo = snap.value as? [String: AnyObject] else { return }
                userInfo["id"] = snap.key as AnyObject
                
                guard let user = User(withDictionary: userInfo) else { return }
                users.append(user)
            }
            
            completion(users)
            
        })
        
    }
    
    
    
}
