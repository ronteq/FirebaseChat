//
//  ChatViewController.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceVertical = true
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    fileprivate let inputSectionContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let messageTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter message"
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        return textField
    }()
    
    fileprivate let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(ChatViewController.sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var user: User!
    
    let messageService = MessageService()

}

//MARK: Life cycle

extension ChatViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        observeForMessages()
    }
    
}

//MARK: Initial setup

extension ChatViewController{
    
    fileprivate func initialSetup(){
        view.backgroundColor = UIColor.white
        navigationItem.title = "Chat with \(user.name)"
        setupViews()
    }
    
    fileprivate func setupViews(){
        setupInputSection()
        setupSeparatorView()
        setupCollectionView()
    }
    
    fileprivate func setupInputSection(){
        view.addSubview(inputSectionContainer)
        
        inputSectionContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        inputSectionContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputSectionContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        inputSectionContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        inputSectionContainer.addSubview(messageTextField)
        inputSectionContainer.addSubview(sendButton)
        
        sendButton.topAnchor.constraint(equalTo: inputSectionContainer.topAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: inputSectionContainer.trailingAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: inputSectionContainer.bottomAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        messageTextField.topAnchor.constraint(equalTo: inputSectionContainer.topAnchor).isActive = true
        messageTextField.leadingAnchor.constraint(equalTo: inputSectionContainer.leadingAnchor, constant: 16).isActive = true
        messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor).isActive = true
        messageTextField.bottomAnchor.constraint(equalTo: inputSectionContainer.bottomAnchor).isActive = true
    }
    
    fileprivate func setupSeparatorView(){
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.lightGray
        
        view.addSubview(separatorView)
        
        separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: inputSectionContainer.topAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    fileprivate func setupCollectionView(){
        view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: inputSectionContainer.topAnchor, constant: -1).isActive = true
    }
    
}

//MARK: Handling methods

extension ChatViewController{
    
    @objc
    fileprivate func sendButtonTapped(){
        
        guard let message = messageTextField.text, message.characters.count > 0 else { return }
        
        sendMessage(message)
    }
    
}

//MARK: Private methods

extension ChatViewController{
    
    fileprivate func observeForMessages(){
        
    }
    
    fileprivate func sendMessage(_ message: String){
        
        let toId = user.id
        
        messageService.sendMessage(toId: toId, message: message)
    }
    
}

//MARK: UICollectionViewDelegate

extension ChatViewController: UICollectionViewDelegate{
    
}

//MARK: UICollectionViewDataSource

extension ChatViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = UIColor.orange
        
        return cell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout

extension ChatViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
}
