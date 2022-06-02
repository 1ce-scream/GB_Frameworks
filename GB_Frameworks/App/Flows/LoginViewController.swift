//
//  LoginViewController.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 23.05.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registrationButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    private lazy var keyboardHelper = KeyboardHelper(scrollView: scrollView)
    
    var alertHelper: AlertsHelper?
    var viewModel: AuthViewModel?
    var onLogin: (() -> Void)?
    var onRegister: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardHelper.hideKeyboardGesture()
        configureButtons()
        configureLoginBindings()
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
    
    private func configureLoginBindings() {
        Observable
            .combineLatest(
                loginTextField.rx.text,
                passwordTextField.rx.text
            )
            .map { login, password in
                return !(login ?? "").isEmpty && (password ?? "").count >= 4
            }
            .subscribe(
                onNext: { [weak self] inputFilled in
                    self?.loginButton?.isEnabled = inputFilled
                },
                onError: { error in
                    print(error.localizedDescription)
                },
                onCompleted: {
                    print("is completed")
                },
                onDisposed: {
                    print("disposed")
                }
            )
            .disposed(by: disposeBag)
    }
    
    @objc func tapLoginButton() {
        let checkResult = viewModel!.checkUserData(login: loginTextField.text ?? "",
                                                   password: passwordTextField.text ?? "")
        if checkResult {
            UserDefaults.standard.set(true, forKey: "isLogin")
            onLogin?()
        } else {
            passwordTextField.text = ""
            alertHelper?.showAlert(title: "Ошибка", message: "Пароль или логин не верны!")
        }
    }
    
    @objc func tapRegButton() {
        onRegister?()
    }
}
