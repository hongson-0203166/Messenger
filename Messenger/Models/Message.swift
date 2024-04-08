//
//  Messeage.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 05/04/2024.
//

import Foundation
import MessageKit
struct Message:MessageType{
    var sender: MessageKit.SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKit.MessageKind
    
}

struct Sender:SenderType{
    var photoURL:String
    var senderId: String
    var displayName: String
}

extension MessageKind{
    var messageKindString:String{
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}
