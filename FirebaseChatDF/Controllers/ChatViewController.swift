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
        cv.register(ChatCell.self, forCellWithReuseIdentifier: "cell")
        cv.register(InconmingChatCell.self, forCellWithReuseIdentifier: "incomingCell")
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
    
    var messages = [Message]()
    
    let messageService = MessageService()

    deinit {
        print("ChatViewController deleted")
        messageService.removeObservers()
    }
    
}

//MARK: Life cycle

extension ChatViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        observeForMessages()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.collectionViewLayout.invalidateLayout()
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
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
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
        
        messageTextField.text = nil
        
    }
    
}

//MARK: Private methods

extension ChatViewController{
    
    fileprivate func observeForMessages(){
        messageService.observeMessagesForUser(user.id) { [weak self] (messages) in
            for message in messages{
                self?.messages.append(message)
            }
            
            OperationQueue.main.addOperation {
                self?.collectionView.reloadData()
            }
        }
    }
    
    fileprivate func sendMessage(_ message: String){
        
        let toId = user.id
        
        messageService.sendMessage(toId: toId, message: message)
    }
    
    fileprivate func estimatedFrameForText(_ text: String)-> CGRect{
        
        let size = CGSize(width: (view.frame.width / 2), height: 100000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
}

//MARK: UICollectionViewDelegate

extension ChatViewController: UICollectionViewDelegate{
    
}

//MARK: UICollectionViewDataSource

extension ChatViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let message = messages[indexPath.item]
        
        if messageService.isMessageFromCurrentUser(message){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChatCell
            cell.messageText.text = message.message
            cell.bubbleWidthAnchor.constant = estimatedFrameForText(message.message).width + ConstraintConstants.widthHeightPlusForEstimation
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "incomingCell", for: indexPath) as! InconmingChatCell
            cell.messageText.text = message.message
            cell.bubbleWidthAnchor.constant = estimatedFrameForText(message.message).width + ConstraintConstants.widthHeightPlusForEstimation
            return cell
        }
        
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout

extension ChatViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = estimatedFrameForText(messages[indexPath.item].message).height + ConstraintConstants.widthHeightPlusForEstimation
        
        return CGSize(width: view.frame.width, height: height)
    }
    
}

//MARK: Constants

extension ChatViewController{
    
    fileprivate struct ConstraintConstants{
        static let widthHeightPlusForEstimation: CGFloat = 25
    }
    
}
