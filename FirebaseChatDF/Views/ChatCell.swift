//
//  ChatCell.swift
//  FirebaseChatDF
//
//  Created by Daniel Fernandez on 9/5/17.
//  Copyright © 2017 Daniel Fernandez. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import AVFoundation

protocol ChatCellDelegate: class{
    
    func chatCellDidTapMessageImageView(_ chatCell: ChatCell)
    
}

class ChatCell: UICollectionViewCell{
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = ImageConstraints.cornerRadius
        view.clipsToBounds = true
        view.backgroundColor = UIColor.orange
        return view
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        return button
    }()
    
    let messageText: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.isUserInteractionEnabled = false
        return tv
    }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = ImageConstraints.cornerRadius
        imageView.backgroundColor = UIColor.white
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint!
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    weak var delegate: ChatCellDelegate?
    
    var message: Message!{
        didSet{
            fillUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    //se llama cada vez que la celda esta por reusarse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
}

extension ChatCell{
    
    func setupViews(){
        setupBubbleView()
        setupMessageLabel()
        setupMessageImageView()
        addTapGestureToImageView()
        setupPlayButton()
        setupActivityIndicatorView()
    }
    
    func setupBubbleView(){
        
    }
    
    func setupMessageLabel(){
        bubbleView.addSubview(messageText)
        
        messageText.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageText.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8).isActive = true
        messageText.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
        messageText.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }
    
    func setupMessageImageView(){
        bubbleView.addSubview(messageImageView)
        
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor).isActive = true
        messageImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
        messageImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
    }
    
    fileprivate func addTapGestureToImageView(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatCell.messageImageViewTapped))
        messageImageView.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setupPlayButton(){
        bubbleView.addSubview(playButton)
        
        playButton.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        playButton.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor).isActive = true
        playButton.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
        playButton.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
    }
    
    fileprivate func setupActivityIndicatorView(){
        bubbleView.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    fileprivate func fillUI(){
        
        if let _ = message.videoUrl, let imageUrl = message.imageUrl{
            messageImageView.isHidden = false
            playButton.isHidden = false
            bubbleWidthAnchor.constant = ImageConstraints.width
            messageImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
            messageImageView.isUserInteractionEnabled = false
            
        }else if let imageUrl = message.imageUrl{
            messageImageView.isHidden = false
            playButton.isHidden = true
            bubbleWidthAnchor.constant = ImageConstraints.width
            messageImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
        }else{
            messageImageView.isHidden = true
            playButton.isHidden = true
            messageText.text = message.message
        }
    }
    
}

//MARK: Handling methods

extension ChatCell{
    
    @objc
    fileprivate func messageImageViewTapped(){
        delegate?.chatCellDidTapMessageImageView(self)
    }
    
    @objc
    fileprivate func playButtonTapped(){
        if let videoUrl = message.videoUrl, let url = URL(string: videoUrl){
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player!)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            playButton.isHidden = true
            activityIndicatorView.startAnimating()
        }
    }
    
}

//MARK: Constants

extension ChatCell{
    
    struct ImageConstraints{
        static let width: CGFloat = 200
        static let cornerRadius: CGFloat = 10
    }
    
}
