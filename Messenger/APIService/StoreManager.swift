//
//  StoreManager.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 02/04/2024.
//

import Foundation
import FirebaseStorage
class StoreManager{
    static let shared = StoreManager()
    let storage = Storage.storage()
    func uploadProfilePhoto(with email:String,image:Data,metaData:StorageMetadata, completion: @escaping (StorageMetadata?,Error?)-> Void){
        let safeEmail = DatabaseManager.shared.safeEmail(email: email)
        storage.reference().child("images/\(safeEmail).jpg").putData(image, metadata: metaData) { data, err in
            guard err == nil else {
                completion(nil, err)
                return
            }
            guard let data = data else {
                completion(nil,err)
                return
            }
            completion(data,nil)
        }
    }
    
    func getDownload(path:String?,completion: @escaping (URL?,Error?)->Void){
        guard let path = path else{
            return
        }
        storage.reference(withPath: path).downloadURL { url, err in
            guard err == nil else{
                completion(nil,err)
                return
            }
            guard let url = url else{
                completion(nil,err)
                return
            }
            completion(url, nil)
        }
    }
}
