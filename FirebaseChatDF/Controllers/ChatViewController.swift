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
        cv.keyboardDismissMode = .interactive
        return cv
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
    
    fileprivate lazy var inputSection: UIView = {
        let inputSection = UIView()
        inputSection.backgroundColor = UIColor.white
        inputSection.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        
        inputSection.addSubview(self.messageTextField)
        inputSection.addSubview(self.sendButton)
        
        self.sendButton.topAnchor.constraint(equalTo: inputSection.topAnchor).isActive = true
        self.sendButton.trailingAnchor.constraint(equalTo: inputSection.trailingAnchor).isActive = true
        self.sendButton.bottomAnchor.constraint(equalTo: inputSection.bottomAnchor).isActive = true
        self.sendButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        self.messageTextField.topAnchor.constraint(equalTo: inputSection.topAnchor).isActive = true
        self.messageTextField.leadingAnchor.constraint(equalTo: inputSection.leadingAnchor, constant: 16).isActive = true
        self.messageTextField.trailingAnchor.constraint(equalTo: self.sendButton.leadingAnchor).isActive = true
        self.messageTextField.bottomAnchor.constraint(equalTo: inputSection.bottomAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.lightGray
        
        inputSection.addSubview(separatorView)
        
        separatorView.leadingAnchor.constraint(equalTo: inputSection.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: inputSection.trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: inputSection.topAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return inputSection
    }()
    
    override var inputAccessoryView: UIView?{
        get{
            return inputSection
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    var timerToUpdateCollectionView: Timer?
    
    var user: User!
    
    var messages = [Message]()
    
    let messageService = MessageService()
    
    deinit {
        print("ChatViewController deleted")
        messageService.removeObservers()
        NotificationCenter.default.removeObserver(self)
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
        setupKeyboardObservers()
        addTapGesture()
    }
    
    fileprivate func setupViews(){
        setupCollectionView()
    }
    
    fileprivate func setupCollectionView(){
        view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ChatViewController.loadOldMessages), for: .valueChanged)
        collectionView.addSubview(refresher)
    }
    
    fileprivate func setupKeyboardObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    fileprivate func addTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
}

//MARK: Handling methods

extension ChatViewController{

    @objc
    fileprivate func loadOldMessages(_ refresher: UIRefreshControl){
        
        guard let oldestMessage = messages.first else { return }
        
        messageService.loadOldMessagesForUser(user.id, lastMessageKey: oldestMessage.messageId) { (messages) in
            refresher.endRefreshing()
            
            var newMessages = messages
            newMessages += self.messages
            self.messages = newMessages
            
            self.collectionView.reloadData()
        }
        
    }
    
    @objc
    fileprivate func sendButtonTapped(){
        
        guard let message = messageTextField.text, message.characters.count > 0 else { return }
        
        sendMessage(message)
        
        messageTextField.text = nil
        
    }
    
    @objc
    fileprivate func handleTap(){
        messageTextField.resignFirstResponder()
    }
    
}

//MARK: Private methods

extension ChatViewController{
    
    @objc
    fileprivate func keyboardWillShow(_ notification: Notification){
        if let info = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey]?.cgRectValue{
            
            collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: keyboardFrame.height + 8, right: 0)
            goToBottomInCollectionView()
            
        }
    }
    
    @objc
    fileprivate func keyboardWillHide(_ notification: Notification){
            
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: inputSection.frame.height + 8, right: 0)
        
    }
    
    fileprivate func observeForMessages(){
        messageService.observeMessagesForUser(user.id) { [weak self] (message) in
            
            self?.messages.append(message)
            
            self?.timerToUpdateCollectionView?.invalidate()
            self?.timerToUpdateCollectionView = Timer.scheduledTimer(timeInterval: 0.1, target: self!, selector: #selector(ChatViewController.updateCollectionView), userInfo: nil, repeats: false)
        }
    }
    
    @objc
    fileprivate func updateCollectionView(){
        OperationQueue.main.addOperation {
            self.collectionView.reloadData()
            self.goToBottomInCollectionView()
        }
    }
    
    fileprivate func sendMessage(_ message: String){
        
        let toId = user.id
        
        messageService.sendMessage(toId: toId, message: message)
        
    }
    
    fileprivate func estimatedFrameForText(_ text: String)-> CGRect{
        let screenWidth = UIScreen.main.bounds.width
        let size = CGSize(width: (screenWidth / 2), height: 100000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    fileprivate func goToBottomInCollectionView(){
        let index = messages.count - 1
        
        if index > 1{
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .bottom, animated: true)
        }
        
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
        
        let screenWidth = UIScreen.main.bounds.width
        let height = estimatedFrameForText(messages[indexPath.item].message).height + ConstraintConstants.widthHeightPlusForEstimation
        
        return CGSize(width: screenWidth, height: height)
    }
    
}

//MARK: Constants

extension ChatViewController{
    
    fileprivate struct ConstraintConstants{
        static let widthHeightPlusForEstimation: CGFloat = 25
    }
    
}
