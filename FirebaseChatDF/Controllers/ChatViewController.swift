//
//  ChatViewController.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class ChatViewController: UIViewController {
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceVertical = true
        cv.register(UserChatCell.self, forCellWithReuseIdentifier: "cell")
        cv.register(InconmingChatCell.self, forCellWithReuseIdentifier: "incomingCell")
        cv.keyboardDismissMode = .interactive
        return cv
    }()
    
    fileprivate lazy var clipImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "clip")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.clipImageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
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
        
        inputSection.addSubview(self.clipImageView)
        inputSection.addSubview(self.messageTextField)
        inputSection.addSubview(self.sendButton)
        
        self.clipImageView.centerYAnchor.constraint(equalTo: inputSection.centerYAnchor).isActive = true
        self.clipImageView.leadingAnchor.constraint(equalTo: inputSection.leadingAnchor, constant: 16).isActive = true
        self.clipImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        self.clipImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        self.sendButton.topAnchor.constraint(equalTo: inputSection.topAnchor).isActive = true
        self.sendButton.trailingAnchor.constraint(equalTo: inputSection.trailingAnchor).isActive = true
        self.sendButton.bottomAnchor.constraint(equalTo: inputSection.bottomAnchor).isActive = true
        self.sendButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        self.messageTextField.topAnchor.constraint(equalTo: inputSection.topAnchor).isActive = true
        self.messageTextField.leadingAnchor.constraint(equalTo: self.clipImageView.trailingAnchor, constant: 16).isActive = true
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
    
    var startingFrameForZoomImageView: CGRect!
    var blackBackgroundView: UIView!
    
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
        navigationItem.title = user.name
        setupViews()
        setupKeyboardObservers()
        addTapGesture()
    }
    
    fileprivate func setupViews(){
        setupCollectionView()
    }
    
    fileprivate func setupCollectionView(){
        view.addSubview(collectionView)
        
        let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "background"))
        backgroundImageView.contentMode = .scaleAspectFit
        
        collectionView.backgroundColor = UIColor(patternImage: backgroundImageView.image!)
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.handleViewTap))
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
    fileprivate func handleViewTap(){
        messageTextField.resignFirstResponder()
    }
    
    @objc
    fileprivate func clipImageViewTapped(){
        
        messageTextField.resignFirstResponder()
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let sendImageAction = UIAlertAction(title: "Send image", style: .default) { (_) in
            self.presentPickerForImages()
        }
        
        let sendVideoAction = UIAlertAction(title: "Send video", style: .default) { (_) in
            self.presentPickerForVideos()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(sendImageAction)
        actionSheet.addAction(sendVideoAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc
    fileprivate func zoomingImageViewIsPanning(_ panGesture: UIPanGestureRecognizer){
        
        guard let zoomingImageView = panGesture.view else { return }
        
        if panGesture.state == .changed{
            
            let translation = panGesture.translation(in: self.view)
            
            zoomingImageView.center = CGPoint(x: zoomingImageView.center.x + translation.x, y: zoomingImageView.center.y + translation.y)
            panGesture.setTranslation(CGPoint.zero, in: self.view)
            
            
        }else if panGesture.state == .ended{
            
            let velocity = panGesture.velocity(in: self.view)
            
            if velocity.x > 150 || velocity.y > 150{
                
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: { 
                    
                    zoomingImageView.frame = self.startingFrameForZoomImageView
                    self.blackBackgroundView.alpha = 0.0
                    self.inputSection.alpha = 1.0
                    
                }, completion: { (_) in
                    
                    zoomingImageView.removeFromSuperview()
                    self.blackBackgroundView.removeFromSuperview()
                    
                })
                
                
            }else{
                guard let keyWindow = UIApplication.shared.keyWindow else { return }
                
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    zoomingImageView.center = keyWindow.center
                }, completion: nil)
            }
            
        }
        
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
        
        messageService.sendMessage(toId: toId, message: message, imageUrl: nil, mediaWidth: nil, mediaHeight: nil, videoUrl: nil)
        
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
    
    fileprivate func presentPickerForImages(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [kUTTypeImage as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func presentPickerForVideos(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func uploadImageToFirebase(imageToSend: UIImage){
        
        if let imageData = UIImageJPEGRepresentation(imageToSend, 0.2){
            
            let width = Double(imageToSend.size.width)
            let height = Double(imageToSend.size.height)
            
            messageService.uploadImageDataToFirebase(imageData, completion: { (imageUrl) in
                self.messageService.sendMessage(toId: self.user.id, message: "image", imageUrl: imageUrl, mediaWidth: width, mediaHeight: height, videoUrl: nil)
            })
        }
        
    }
    
    fileprivate func uploadVideoToFirebase(videoUrlToSend videoUrl: URL){
        
        if let thumbnailImageForUrl = thumbnailImageForUrl(fileUrl: videoUrl), let thumnailImage = UIImageJPEGRepresentation(thumbnailImageForUrl, 0.2){
            
            let width = Double(thumbnailImageForUrl.size.width)
            let height = Double(thumbnailImageForUrl.size.height)
            
            messageService.uploadVideoUrlToFirebase(videoUrl, completion: { (videoUrl) in
                
                self.messageService.uploadImageDataToFirebase(thumnailImage, completion: { (imageUrl) in
                    
                    self.messageService.sendMessage(toId: self.user.id, message: "video", imageUrl: imageUrl, mediaWidth: width, mediaHeight: height, videoUrl: videoUrl)
                    
                })
                
            })
            
        }
        
    }
    
    fileprivate func thumbnailImageForUrl(fileUrl: URL)-> UIImage?{
        
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do{
            
            let thumnailCGImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            
            return UIImage(cgImage: thumnailCGImage)
            
        }catch{
            print(error.localizedDescription)
        }
        
        return nil
        
    }
    
    fileprivate func animateZoomInForMessageImageView(for chatCell: ChatCell){
        setupBlackBackgroundiew()
        
        if let zoomingImageView = setupZoomingImageView(for: chatCell){
            animateZoomIn(zoomingImageView)
        }
    }
    
    fileprivate func setupBlackBackgroundiew(){
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        blackBackgroundView = UIView(frame: keyWindow.frame)
        blackBackgroundView.backgroundColor = UIColor.black
        blackBackgroundView.alpha = 0.0
        
        keyWindow.addSubview(blackBackgroundView)
        
    }
    
    fileprivate func setupZoomingImageView(for chatCell: ChatCell)-> UIImageView?{
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return nil }
        
        startingFrameForZoomImageView = chatCell.messageImageView.superview?.convert(chatCell.messageImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrameForZoomImageView)
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.image = chatCell.messageImageView.image
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ChatViewController.zoomingImageViewIsPanning))
        zoomingImageView.addGestureRecognizer(panGesture)
        
        keyWindow.addSubview(zoomingImageView)
        
        return zoomingImageView
    }
    
    fileprivate func animateZoomIn(_ zoomingImageView: UIImageView){
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            
            self.blackBackgroundView.alpha = 1.0
            self.inputSection.alpha = 0.0
            
            let height = self.startingFrameForZoomImageView!.height / self.startingFrameForZoomImageView!.width * keyWindow.frame.width
            
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            zoomingImageView.center = keyWindow.center
            
        }, completion: nil)
        
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UserChatCell
            cell.delegate = self
            cell.bubbleWidthAnchor.constant = estimatedFrameForText(message.message).width + ConstraintConstants.widthHeightPlusForEstimation + 10
            cell.message = message
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "incomingCell", for: indexPath) as! InconmingChatCell
            cell.delegate = self
            cell.bubbleWidthAnchor.constant = estimatedFrameForText(message.message).width + ConstraintConstants.widthHeightPlusForEstimation + 10
            cell.message = message
            return cell
        }
        
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout

extension ChatViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        
        if let imageHeight = messages[indexPath.item].mediaHeight,
            let imageWidth = messages[indexPath.item].mediaWidth{
            
            let height = CGFloat(imageHeight / imageWidth) * ChatCell.ImageConstraints.width
            
            return CGSize(width: screenWidth, height: height)
        }else{
            let height = estimatedFrameForText(messages[indexPath.item].message).height + ConstraintConstants.widthHeightPlusForEstimation
            return CGSize(width: screenWidth, height: height)
        }
    }
    
}

//MARK: UIImagePickerControllerDelegate - UINavigationControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            
            uploadVideoToFirebase(videoUrlToSend: videoUrl)
            
        }else{
            
            var selectedImageForPicker: UIImage?
            
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
                selectedImageForPicker = editedImage
            }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
                selectedImageForPicker = originalImage
            }
            
            if let selectedImage = selectedImageForPicker{
                uploadImageToFirebase(imageToSend: selectedImage)
            }
            
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

//MARK: ChatCellDelegate

extension ChatViewController: ChatCellDelegate{
    
    func chatCellDidTapMessageImageView(_ chatCell: ChatCell) {
        
        animateZoomInForMessageImageView(for: chatCell)
        
    }
    
}

//MARK: Constants

extension ChatViewController{
    
    fileprivate struct ConstraintConstants{
        static let widthHeightPlusForEstimation: CGFloat = 25
    }
    
}
