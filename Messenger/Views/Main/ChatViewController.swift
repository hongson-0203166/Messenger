//
//  ChatViewController.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 01/04/2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView
class ChatViewController: MessagesViewController {
    public static var dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    public var otherUserEmail:String = ""
    private var conversationID:String?
    public var isNewConversation = false
    private var messages = [Message]()
    
    private var selfSender:Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmailCurrent = DatabaseManager.shared.safeEmail(email: email)
       return  Sender(photoURL: "",
               senderId: safeEmailCurrent,
               displayName: "Me")
    }
    
   
    init(with email:String,id:String?) {
        self.conversationID = id ?? ""
        self.otherUserEmail = email
        print("Conversation id: \(self.conversationID) và email:\(self.otherUserEmail)")
        super.init(nibName: nil, bundle: nil)
        if let conversationID = conversationID{
            listenForMessages(id: conversationID,shouldScrollToBottom:true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        // Do any additional setup after loading the view.
        print(UserDefaults.standard.string(forKey: "email"))
        
    }
    private func listenForMessages(id:String,shouldScrollToBottom:Bool){
        DatabaseManager.shared.getAllMessagesofConversation(with: id) {[weak self] results in
            switch results{
            case .failure(let error):
                print("faild to \(error)")
                break
            case .success(let messages):
                guard !messages.isEmpty else{
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom{
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
                break
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }

}
extension ChatViewController:InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageID = createMessageID() else{return}
        
        
        print("Sending: \(text)")
        if isNewConversation{
            //create newconversation
            let mmessage = Message(sender: selfSender,
                                   messageId: messageID,
                                   sentDate: Date(),
                                   kind: .text(text))
            DatabaseManager.shared.createNewconversation(with: otherUserEmail, mname: self.title ?? "User",firstMessage: mmessage) { success in
                if success {
                    print("message sent")
                }else{
                    print("faild to send")
                }
            }
        }else{
            
        }
    }
    private func createMessageID()->String?{
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else{return nil}
        let safeEmailOther = DatabaseManager.shared.safeEmail(email: otherUserEmail)
        let safeEmailCurrent = DatabaseManager.shared.safeEmail(email: currentUserEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        
        let newIdentifier = "\(safeEmailOther)_\(safeEmailCurrent)_\(dateString)"
        print("Create message id:\(newIdentifier)")
        
        return newIdentifier
    }
}
extension ChatViewController:MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate{
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("Self send is nil, email should be cached")
      
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
