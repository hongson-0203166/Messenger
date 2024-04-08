//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Phạm Hồng Sơn on 24/03/2024.
//

import UIKit
import FirebaseAuth
class RegisterViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorEmailView: UIView!
    @IBOutlet weak var errorEmailLable: UILabel!
    
    @IBOutlet weak var errorPassView: UIView!
    @IBOutlet weak var errorPassLable: UILabel!
    
    //MARK: View did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let tapGeture = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(tapGeture)
        setupView()
    }
    @objc func hideKeyBoard(){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    func setupView(){
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.masksToBounds = true
        emailTextField.returnKeyType = .continue
        emailTextField.placeholder = "Email Address..."
        emailTextField.keyboardType = .emailAddress
        emailTextField.delegate = self
        
        passwordTextField.delegate = self
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.masksToBounds = true
        passwordTextField.placeholder = "Password..."
        passwordTextField.keyboardType = .emailAddress
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        
        signUpButton.layer.cornerRadius = 8
        signUpButton.layer.masksToBounds = true
        errorEmailView.isHidden = true
        errorPassView.isHidden = true
        signUpButton.isEnabled = false
    }
    private func setupEmailError(error:String) {
        errorEmailView.isHidden = false
        errorEmailLable.text = error
        emailTextField.layer.borderWidth = 1
       
        emailTextField.layer.borderColor = UIColor(red: 222/256, green: 112/256, blue: 101/256, alpha: 1).cgColor
        
    }
    private func setupEmailValid() {
        errorEmailView.isHidden = true
        errorEmailLable.text = nil
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        emailTextField.backgroundColor = UIColor.white
    }
    private func setupPasswordError(error:String) {
        errorPassView.isHidden = false
        errorPassLable.text = error
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor(red: 222/256, green: 112/256, blue: 101/256, alpha: 1).cgColor
    }
    private func setupPasswordValid() {
        errorPassView.isHidden = true
        errorPassLable.text = nil
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.backgroundColor = UIColor.white
    }
    //
    //
    //MARK: Valid Func
    //
    //
    private func updateSignUpButtonState(){
            let email = emailTextField.text ?? ""
            let password = passwordTextField.text ?? ""
        signUpButton.isEnabled = (!email.isEmpty && !password.isEmpty)
        }
    //
    //
    //MARK: Main func
    //
    //
    @IBAction func onHandleSignup(_ sender: UIButton) {
        switch sender{
        case signUpButton:
            onSignUp()
            break
        case loginButton:
            self.navigationController?.popViewController(animated: true)
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
    func onSignUp(){
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        if onHandleValidateForm(email: email, password: password) == true{
            UserDefaults.standard.set(email, forKey: "email")
            //validate userExists
            DatabaseManager.shared.userExist(with: email) {[weak self] exists in
                guard exists else{
                    self?.alertSignUpError()
                    return
                }
                
                //Create Newuser
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    guard authResult != nil, error == nil else{
                        print("Error createUser")
                        return
                    }
                    let user = User(first_name: "", last_name: "", user_name: "", phone_number: "", emailAddress: email, urlAvatar: "")
                    DatabaseManager.shared.insertUser(with: user)

                    let vc = AddProfileViewController()
                    vc.safeEmail = email
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
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
    func alertSignUpError(message:String = "User exists, please login."){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}
extension RegisterViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
                onSignUp()
        }else{
            emailTextField.becomeFirstResponder()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSignUpButtonState()
        return true
    }
}
