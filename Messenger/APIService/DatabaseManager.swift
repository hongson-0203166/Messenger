//
//  Datamanager.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 26/03/2024.
//

import Foundation
import FirebaseDatabase
final class DatabaseManager{
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    public func safeEmail(email:String) -> String {
            var safeEmail = email.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            return safeEmail
        }
}

//MARK: Account Manager
extension DatabaseManager{
    public func userExist(with email:String,
                          completion:@escaping (Bool)->Void){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value != nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    public func insertUser(with user:User){
        let userDict: [String: Any] = [
                "first_name": user.first_name,
                "last_name": user.last_name,
                "user_name": user.last_name + " " + user.first_name,
                "phone_number":user.phone_number,
                "emailAddress": user.emailAddress,
                "urlAvatar": user.urlAvatar
            ]
        let safeEmail = user.safeEmail()
        database.child(safeEmail).setValue(userDict) { error, _ in
            guard  error == nil else{
                print("failed to write database")
                return
            }
        }
    }
    
    
    
    
    public func updateUser(user:User,completion: @escaping (Error?)->Void){
        let userDict: [String: Any] = [
                "first_name": user.first_name,
                "last_name": user.last_name,
                "user_name": user.last_name + " " + user.first_name,
                "phone_number": user.phone_number,
                "urlAvatar": user.urlAvatar
            ]
        
        
        let safeEmail1 = user.safeEmail()
        print("SafeEmail: \(safeEmail1)")
        // Đường dẫn đến người dùng cần cập nhật
            let userRef = database.child(safeEmail1)
        userRef.updateChildValues(userDict) { error, _ in
                if let error = error {
                    print("Failed to update user in database:", error.localizedDescription)
                    completion(error)
                    return
                }
                print("User updated successfully")
                completion(nil)
            }
    }
    
   public func setUser(email:String,name:String){
       self.database.child("users").observeSingleEvent(of: .value) { snapshot in
           if var userCollection = snapshot.value as? [[String:String]]{
               //append to user dictionary
               let newElement = [
                   "name":name,
                   "email":DatabaseManager.shared.safeEmail(email: email)
               ]
               userCollection.append(newElement)
               self.database.child("users").setValue(userCollection) { err, _ in
                   guard err == nil else{
   
                       return
                   }
   
               }
           }else{
               //create that arrayf
               let newCollection :[[String:String]] = [
                   [
                       "name":name,
                       "email":DatabaseManager.shared.safeEmail(email: email)
                   ]
               ]
               self.database.child("users").setValue(newCollection) { err, _ in
                   guard err == nil else{
                       return
                   }
   
               }
           }
       }
    }
    
    
    func getAllUser(completion:@escaping (Result<[[String:String]],Error>)->Void){
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String:String]] else{
                completion(.failure(DatabaseError.failgetUsers))
                return
            }
            completion(.success(value))
        }
    }
    public enum DatabaseError:Error{
        case  failgetUsers
        case  failgetConversation
        case  failgetMessage
    }
    
}
//MARK: Sending messages
extension DatabaseManager{
   
    
    public func createNewconversation(with otherUserEmail:String,mname :String,firstMessage:Message,completion:@escaping(Bool)->Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        
        let safeEmailCurrent = DatabaseManager.shared.safeEmail(email: currentEmail)
        let safeEmailOther = DatabaseManager.shared.safeEmail(email: otherUserEmail)
        let ref = database.child("\(safeEmailCurrent)")

        ref.observeSingleEvent(of: .value) { snapshot  in
            guard var value = snapshot.value as? [String:Any] else{
                completion(false)
                print("user not found")
                return
            }
            var message = ""
            switch firstMessage.kind{
                
            case .text(let messageText):
                message = messageText
                break
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            let conversationID = "conversations_\(firstMessage.messageId)"
            let newConversation = [
                "id":conversationID,
                "other_user_email":safeEmailOther,
                "name":mname,
                "latest_message":[
                    "date":dateString,
                    "message":message,
                    "is_read":false
                ]
                
            ]
            
            let recipient_newConversation = [
                "id":conversationID,
                "other_user_email": safeEmailCurrent,
                    "name":"Self",
                "latest_message":[
                    "date":dateString,
                    "message":message,
                    "is_read":false
                ]
                
            ]
            
            //Update recipient conversatoin entry
            self.database.child("\(safeEmailOther)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
                if var snapshot = snapshot.value as? [[String:Any]]{
                    //append
                    snapshot.append(recipient_newConversation)
                    self?.database.child("\(safeEmailOther)/conversations").setValue(conversationID)
                }else{
                    //create
                    self?.database.child("\(safeEmailOther)/conversations").setValue([recipient_newConversation])
                }
            }
            
            
            //Update current user conversation entry
            if var conversations = value["conversations"] as? [[String:Any]]{
                conversations.append(newConversation)
                value["conversations"] = conversations
                self.database.child("\(safeEmailCurrent)").setValue(value){error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self.finishCreateConversation(conversationID: conversationID, name: mname, fistMessage: firstMessage, completion: completion)
                    
                }
            }else{
                value["conversations"] = [
                    newConversation
                ]
                self.database.child("\(safeEmailCurrent)").setValue(value){error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self.finishCreateConversation(conversationID: conversationID, name: mname, fistMessage: firstMessage, completion: completion)
                   
                }
            }
        }
    }
    
    private func finishCreateConversation(conversationID:String,name:String,
                                          fistMessage:Message,completion:@escaping((Bool)->Void)){
        var message = ""
        switch fistMessage.kind{
            
        case .text(let messageText):
            message = messageText
            break
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let messageDate = fistMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        guard let currentEmail = UserDefaults.standard.string(forKey: "email") as?String else{
            completion(false)
            return
        }
        
        let safeEmailCurrent = DatabaseManager.shared.safeEmail(email: currentEmail)
        let value:[String:Any] = [
            "message":[
                [
                "id": fistMessage.messageId,
                "type": fistMessage.kind.messageKindString,
                "name":name,
                "content":message,
                "date":dateString,
                "sender_email":safeEmailCurrent,
                "is_read":false
                ]
            ]
        ]
        database.child("\(conversationID)").setValue(value){ error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    //getAllConversation
    public func getAllConversations(for email:String,completion:@escaping(Result<[Conversation],Error>)->Void){
        database.child("\(email)/conversations").observe(.value) { snapshot  in
                guard let value = snapshot.value as? [[String: Any]] else {
                    completion(.failure(DatabaseError.failgetConversation))
                    return
                }
                
                let conversations: [Conversation] = value.compactMap { dictionary in
                    guard let conversationID = dictionary["id"] as? String,
                          let name = dictionary["name"] as? String,
                          let otherEmail = dictionary["other_user_email"] as? String,
                          let latestMessage = dictionary["latest_message"] as? [String: Any],
                          let date = latestMessage["date"] as? String,
                          let message = latestMessage["message"] as? String,
                          let isRead = latestMessage["is_read"] as? Bool
                    else {
                        return nil
                    }
                    
                    let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                    return Conversation(id: conversationID, name: name, otherUserEmail: otherEmail, latestMessage: latestMessageObject)
                }
                
                completion(.success(conversations))
            }
        
    }
    //get all mmessages for a given conversation for the user with passed in email
    public func getAllMessagesofConversation(with id:String,completion:@escaping(Result<[Message],Error>)->Void){
        database.child("\(id)/messages").observe(.value) { snapshot  in
                guard let value = snapshot.value as? [[String: Any]] else {
                    completion(.failure(DatabaseError.failgetConversation))
                    return
                }
                
            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as?String,
                      let isRead = dictionary["is_read"] as?Bool,
                      let messageId = dictionary["id"] as?String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as?String,
                      let dateString = dictionary["date"] as? String,
                let date = ChatViewController.dateFormatter.date(from: dateString) else{
                    return nil
                }
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                return Message(sender: sender,
                               messageId: messageId,
                               sentDate: date,
                               kind: .text(content))
                }
            completion(.success(messages))
            }
    }
    //Send a message with target conversation and message
    public func sendMessage(to conversatioin:String,mmessage:Message,completion:@escaping(Bool)->Void){
        
    }
    
    
}
