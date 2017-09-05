//
//  AuthViewController.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import UIKit

extension UIViewController{
    func createDefaultAlert(message: String){
        let alert = UIAlertController(title: "DF", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}

class AuthViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let userService = UserService()
    
    @IBAction func loginBtnTapped() {
        login()
    }
}

//MARK: Life cycle

extension AuthViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLogged()
    }
    
}

//MARK: Private methods

extension AuthViewController{
    
    fileprivate func checkIfUserIsLogged(){
        if userService.isUserLogged(){
            self.pushToHomeViewController()
        }
    }
    
    fileprivate func login(){
        guard let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        
        userService.login(email: email, password: password) { (errorMessage) in
            
            if let errorMessage = errorMessage{
                self.createDefaultAlert(message: errorMessage)
            }else{
                self.pushToHomeViewController()
            }
            
        }
    }
    
    fileprivate func pushToHomeViewController(){
        let homeController = HomeViewController()
        self.navigationController?.pushViewController(homeController, animated: true)
    }
    
}

