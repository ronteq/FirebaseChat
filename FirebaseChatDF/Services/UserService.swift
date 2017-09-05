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
    
    private func saveUserInformation(_ email: String, uid: String){
        let databaseRef = Database.database().reference()
        let userRef = databaseRef.child(FirebasePaths.users).child(uid)
        
        userRef.setValue(["email": email])
    }
    
}
