//
//  LoginViewController.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 24/03/2024.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var faceBookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!

    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var emailErrorView: UIView!
    @IBOutlet weak var emailErrorLable: UILabel!
    
    @IBOutlet weak var passwordErrorView: UIView!
    @IBOutlet weak var passwordErrorLable: UILabel!
    
    @IBOutlet weak var faceView: UIView!
    
    @IBOutlet weak var googleView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
        
        // Đăng ký sự kiện bàn phím xuất hiện và biến mất
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Thêm UITapGestureRecognizer để ẩn bàn phím khi người dùng chạm vào bất kỳ nơi nào trên màn hình
               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               scrollView.addGestureRecognizer(tapGesture)
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
    
    func setupView(){
        
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.masksToBounds = true
        emailTextField.becomeFirstResponder()
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .continue
        emailTextField.placeholder = "Email Address..."
        emailTextField.delegate = self
        
        passwordTextField.delegate = self
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.masksToBounds = true
        passwordTextField.keyboardType = .emailAddress
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "Password..."
        passwordTextField.returnKeyType = .done
        
        LoginButton.layer.cornerRadius = 8
        LoginButton.layer.masksToBounds = true
        faceView.layer.cornerRadius = 8
        faceView.layer.masksToBounds = true
        googleView.layer.cornerRadius = 8
        googleView.layer.masksToBounds = true
        emailErrorView.isHidden = true
        passwordErrorView.isHidden = true
        LoginButton.isEnabled = false
    }
    
    private func setupEmailError(error:String) {
        emailErrorView.isHidden = false
        emailErrorLable.text = error
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor(red: 222/256, green: 112/256, blue: 101/256, alpha: 1).cgColor
    }
    private func setupEmailValid() {
        emailErrorView.isHidden = true
        emailErrorLable.text = nil
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        emailTextField.backgroundColor = UIColor.white
    }
    private func setupPasswordError(error:String) {
        passwordErrorView.isHidden = false
        passwordErrorLable.text = error
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor(red: 222/256, green: 112/256, blue: 101/256, alpha: 1).cgColor
    }
    private func setupPasswordValid() {
        passwordErrorView.isHidden = true
        passwordErrorLable.text = nil
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.backgroundColor = UIColor.white
    }
    
    private func updateSignInButtonState(){
            let email = emailTextField.text ?? ""
            let password = passwordTextField.text ?? ""
            LoginButton.isEnabled = !email.isEmpty && !password.isEmpty
        }
    //
    //
    //MARK: Main func
    //
    //
    @IBAction func onHandleSignup(_ sender: UIButton) {
        switch sender{
        case LoginButton:
            onSignIn()
            break
        case faceBookButton:
            print("Tính năng đang phát triển")
            break
        case googleButton:
            print("Tính năng đang phát triển")
            break
        case signUpButton:
            navigationController?.pushViewController(RegisterViewController(), animated: true)
            break
        default:
            break
        }
    }
    
    //
    //
    //MARK: Sign up
    //
    //
    func onSignIn(){
        let email = emailTextField.text ?? ""
        UserDefaults.standard.set(email, forKey: "email")
        
        let password = passwordTextField.text ?? ""
        if onHandleValidateForm(email: email, password: password) == true{
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
                guard let authResult = authResult, error == nil else{
                    print("Login email faild")
                    return
                }
                
                let user = authResult.user
                
                
                print("Login user: \(user)")
                self?.navigationController?.dismiss(animated: true)
            }
        }
    }
    //
    //
    //MARK: Validate Form
    //
    //
    private func onHandleValidateForm(email: String, password: String) -> Bool {
        var isvalidEmail = false
        var isvalidPassword = false
         if isValidEmail(email){
            setupEmailValid()
            isvalidEmail = true
        }else{
            setupEmailError(error: "Email invalid")
            isvalidEmail = false
        }
        
        if password.count >= 6{
            setupPasswordValid()
            isvalidPassword = true
        }else{
            setupPasswordError(error: "Character more than 6")
            isvalidPassword = false
        }
        return isvalidEmail && isvalidPassword
    }
    //
    //
    //MARK: Regex Email
    //
    //
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}
extension LoginViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
            
                onSignIn()
            
        }else{
            emailTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSignInButtonState()
        return true
    }
    
}
