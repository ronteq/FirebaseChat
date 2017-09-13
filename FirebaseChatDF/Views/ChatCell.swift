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
    
}

extension ChatCell{
    
    func setupViews(){
        setupBubbleView()
        setupMessageLabel()
        setupMessageImageView()
        addTapGestureToImageView()
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
    
    fileprivate func fillUI(){
        if let imageUrl = message.imageUrl{
            messageImageView.isHidden = false
            bubbleWidthAnchor.constant = ImageConstraints.width
            messageImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
        }else{
            messageImageView.isHidden = true
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
    
}

//MARK: Constants

extension ChatCell{
    
    struct ImageConstraints{
        static let width: CGFloat = 200
        static let cornerRadius: CGFloat = 10
    }
    
}
