//
//  User.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 26/03/2024.
//

import Foundation
struct User{
    let first_name:String
    let last_name:String
    let user_name:String
    let phone_number:String
    let emailAddress:String
    let urlAvatar:String
    
    func safeEmail() -> String {
            var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            return safeEmail
        }
}
