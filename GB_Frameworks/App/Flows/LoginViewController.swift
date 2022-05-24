//
//  LoginViewController.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 23.05.2022.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var LoginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registrationButton: UIButton!
    
    private lazy var alert = AlertsHelper(viewController: self)
    private lazy var viewModel = LoginViewModel()
    private lazy var keyboardHelper = KeyboardHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardHelper.scrollView = scrollView
        keyboardHelper.hideKeyboardGesture()
        configureButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        keyboardHelper.addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardHelper.removeKeyboardObserver()
    }
    
    private func configureButtons() {
        loginButton.tintColor = .systemGreen
        loginButton.addTarget(self,
                              action: #selector(tapLoginButton),
                              for: .touchUpInside)
        registrationButton.tintColor = .systemTeal
        registrationButton.addTarget(self,
                                     action: #selector(tapRegButton),
                                     for: .touchUpInside)
    }
    
    private func checkTextFields() -> Bool {
        guard let login = LoginTextField.text,
              let password = passwordTextField.text
        else {
            return false
        }
        
        guard !login.isEmpty,
              !password.isEmpty
        else {
            alert.showAlert(title: "Ошибка", message: "Необходимо заполнить все поля")
            return false
        }
        
        return true
    }
    
    @objc func tapLoginButton() {
        
        guard checkTextFields() else { return }
        
        let checkResult = viewModel.checkUserData(login: LoginTextField.text ?? "",
                                                  password: passwordTextField.text ?? "")
        
        if checkResult {
            performSegue(withIdentifier: "loginToMap", sender: nil)
        } else {
            alert.showAlert(title: "Ошибка", message: "Пароль или логин не верны!")
        }
    }
    
    @objc func tapRegButton() {
        
        guard checkTextFields() else { return }
        
        let isUserExist = viewModel.registerUser(login: LoginTextField.text ?? "",
                                                 password: passwordTextField.text ?? "")
        
        if isUserExist {
            alert.showAlert(title: "Отлично", message: "Пароль был изменен!")
        } else {
            alert.showAlert(title: "Отлично", message: "Успешная регистрация")
        }
    }
}
