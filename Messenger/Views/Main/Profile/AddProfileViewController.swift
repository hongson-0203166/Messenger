//
//  AddProfileViewController.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 02/04/2024.
//

import UIKit
import SnapKit
import PhotosUI
import FirebaseStorage
class AddProfileViewController: UIViewController{
    public var safeEmail:String? = ""
    private let scrollView :UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .onDrag
        return scroll
    }()
    private let avatarImage :UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 60
        image.backgroundColor = .lightGray
        image.image = UIImage(systemName: "person.crop.circle")
        image.tintColor = .gray
        image.isUserInteractionEnabled = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    private let firstnameTextField:UITextField = {
      
        let textField = UITextField()
        textField.placeholder = "First name"
        textField.keyboardType = .default
        textField.leftViewMode = .always
        textField.becomeFirstResponder()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        textField.backgroundColor = .secondarySystemFill
        textField.returnKeyType = .done
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 8
        
        return textField
    }()
    
    private let lastnameTextField:UITextField = {
       let textField = UITextField()
        textField.placeholder = "Last name"
        textField.keyboardType = .default
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        textField.backgroundColor = .secondarySystemFill
        textField.returnKeyType = .done
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private let phonenumberTextField:UITextField = {
       let textField = UITextField()
        textField.placeholder = "Phone number"
        textField.keyboardType = .default
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        textField.backgroundColor = .secondarySystemFill
        textField.returnKeyType = .done
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private let submitButton:UIButton = {
       let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16,weight: .bold)
        button.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    private let avatarButton:UIButton = {
       let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(avatarImage)
        scrollView.addSubview(firstnameTextField)
        scrollView.addSubview(lastnameTextField)
        scrollView.addSubview(phonenumberTextField)
        scrollView.addSubview(submitButton)
        
        scrollView.addSubview(avatarButton)
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        phonenumberTextField.delegate = self
        view.backgroundColor = .systemBackground
        configureConstrains()
        setScrollView()
        submitButton.addTarget(self, action: #selector(submitProfile), for: .touchUpInside)
        avatarButton.addTarget(self, action:#selector(didtapUpload), for: .touchUpInside)
    }
    @objc func didtapUpload(){
        print("upload avatar")
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    @objc func submitProfile(){
        updateUser()
        navigationController?.dismiss(animated: true)
    }
    func updateUser(){
        print("SafeEmail: \(safeEmail)")
        
        guard let image = avatarImage.image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        StoreManager.shared.uploadProfilePhoto(with: safeEmail ?? "", image: image, metaData: metadata) { metadata, error in
            if error != nil{
                print("Lỗi: \(String(describing: error?.localizedDescription))")
            }
            
            print("metaData: \(String(describing: metadata))")
            let path = metadata?.path
            StoreManager.shared.getDownload(path: path) { url, error in
                if error != nil{
                    print("Lỗi \(String(describing: error?.localizedDescription))")
                }
                
                print("URL: \(String(describing: url))")
                
                
            let urlAvt = url?.absoluteString
            guard let first = self.firstnameTextField.text,
                                let last = self.lastnameTextField.text,
                                let phone = self.phonenumberTextField.text else {
                                return
                            }
                let user = User(first_name: first, last_name: last, user_name: last + " " + first, phone_number: phone, emailAddress: self.safeEmail ?? "", urlAvatar: urlAvt ?? "")
                DatabaseManager.shared.updateUser(user: user) { error in
                                guard error == nil else{
                                    print("Lỗi \(error?.localizedDescription)")
                                    return
                                }
                    
                    DatabaseManager.shared.setUser(email: self.safeEmail ?? "", name: last + " " + first)
                            }
            }
        }
    }
    func setScrollView(){
        // Đăng ký sự kiện bàn phím xuất hiện và biến mất
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Thêm UITapGestureRecognizer để ẩn bàn phím khi người dùng chạm vào bất kỳ nơi nào trên màn hình
               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               scrollView.addGestureRecognizer(tapGesture)
    }
    private func updateSignInButtonState(){
        let first = firstnameTextField.text ?? ""
        let last = lastnameTextField.text ?? ""
        let phone = phonenumberTextField.text ?? ""
        submitButton.isEnabled = !first.isEmpty && !last.isEmpty && !phone.isEmpty
        submitButton.alpha = submitButton.isEnabled ? 1.0 : 0.5
        
        }
    @objc func keyboardWillShow(notification: Notification) {
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            scrollView.contentInset.bottom = keyboardFrame.height
        }
        
    @objc func keyboardWillHide(notification: Notification) {
            scrollView.contentInset.bottom = 0
        }
        
    @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    
    func configureConstrains(){
        scrollView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        avatarImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.width.height.equalTo(120)
            make.centerX.equalToSuperview()
        }
        avatarButton.snp.makeConstraints { make in
            make.top.width.height.centerX.equalTo(avatarImage)
        }
        firstnameTextField.snp.makeConstraints { make in
            make.top.equalTo(avatarImage.snp.bottom).offset(24)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
        }
        lastnameTextField.snp.makeConstraints { make in
            make.top.equalTo(firstnameTextField.snp.bottom).offset(16)
            make.height.equalTo(48)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
        }
        phonenumberTextField.snp.makeConstraints { make in
            make.top.equalTo(lastnameTextField.snp.bottom).offset(16)
            make.height.equalTo(48)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
        }
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(phonenumberTextField.snp.bottom).offset(16)
            make.height.equalTo(48)
            make.width.equalTo(160)
            make.centerX.equalToSuperview()
        }
    }
    
}
extension AddProfileViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstnameTextField{
            lastnameTextField.becomeFirstResponder()
        }else if textField == lastnameTextField{
            phonenumberTextField.becomeFirstResponder()
        }else if textField == phonenumberTextField{
            submitProfile()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSignInButtonState()
        return true
    }
    
}
extension AddProfileViewController:PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage{
                    DispatchQueue.main.sync {
                        self?.avatarImage.image = image
                    }
                }
            }
        }
    }
}
