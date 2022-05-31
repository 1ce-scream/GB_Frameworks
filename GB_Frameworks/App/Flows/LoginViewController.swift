//
//  LoginViewController.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 23.05.2022.
//

import UIKit

final class LoginViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registrationButton: UIButton!
    
    private lazy var alert = AlertsHelper(viewController: self)
    private lazy var keyboardHelper = KeyboardHelper(scrollView: scrollView)
    
    var viewModel: AuthViewModel?
    var onLogin: (() -> Void)?
    var onRegister: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        guard
            let login = loginTextField.text,
            let password = passwordTextField.text,
            !login.isEmpty,
            !password.isEmpty
        else {
            alert.showAlert(title: "Ошибка", message: "Необходимо заполнить все поля")
            return false
        }
        return true
    }
    
    @objc func tapLoginButton() {
        
        guard checkTextFields() else { return }
        
        let checkResult = viewModel!.checkUserData(login: loginTextField.text ?? "",
                                                  password: passwordTextField.text ?? "")
        
        if checkResult {
            UserDefaults.standard.set(true, forKey: "isLogin")
            onLogin?()
        } else {
            alert.showAlert(title: "Ошибка", message: "Пароль или логин не верны!")
        }
    }
    
    @objc func tapRegButton() {
        onRegister?()
    }
}
