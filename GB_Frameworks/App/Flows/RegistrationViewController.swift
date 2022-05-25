//
//  RegistrationViewController.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 25.05.2022.
//

import UIKit

final class RegistrationViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registrationButton: UIButton!
    
    private lazy var alert = AlertsHelper(viewController: self)
    private lazy var keyboardHelper = KeyboardHelper(scrollView: scrollView)
    
    var viewModel: LoginViewModel?
    var onLogin: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureButtons()
        keyboardHelper.hideKeyboardGesture()
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
    
    @objc func tapRegButton() {
        guard checkTextFields() else { return }
        
        let action = UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            self?.onLogin?()
        }
        
        guard let isUserExist = viewModel?.registerUser(login: loginTextField.text ?? "",
                                                        password: passwordTextField.text ?? "")
        else {
            print("smth went wrong with view model")
            return
        }

        if isUserExist {
            alert.showAlert(title: "Отлично", message: "Пароль был изменен!", externalAction: action)
        } else {
            alert.showAlert(title: "Отлично", message: "Успешная регистрация", externalAction: action)
        }
    }
}
