//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 07/04/2024.
//

import UIKit
import Kingfisher
import SnapKit

class ConversationTableViewCell: UITableViewCell {
    static let identifier = "ConversationTableViewCell"
    let userImageview :UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 30
        image.layer.masksToBounds = true
        return image
    }()
    
    private let userNameLable :UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 21,weight: .semibold)
        return lable
    }()
    private let userMessageLable :UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 16,weight: .regular)
        lable.numberOfLines = 1
        return lable
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageview)
        contentView.addSubview(userNameLable)
        contentView.addSubview(userMessageLable)
        configureConstrain()
    }
    func configureConstrain(){
        userImageview.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.height.width.equalTo(60)
        }
        
        userNameLable.snp.makeConstraints { make in
            make.top.equalTo(userImageview).offset(5)
            make.leading.equalTo(userImageview.snp.trailing).offset(5)
        }
        userMessageLable.snp.makeConstraints { make in
            make.top.equalTo(userNameLable.snp.bottom).offset(7)
            make.leading.equalTo(userImageview.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model:Conversation){
//        self.userImageview =
        self.userNameLable.text = model.name
        self.userMessageLable.text = model.latestMessage.text
        
        
        let path = "images/\(model.otherUserEmail).jpg"
        StoreManager.shared.getDownload(path: path) {[weak self] url, error in
            if error != nil{
                print("Lỗi dowload: \(String(describing: error)) ")
                return
            }
            if url != nil{
                self?.userImageview.kf.setImage(with: url)
            }
        }
    }
    
}
