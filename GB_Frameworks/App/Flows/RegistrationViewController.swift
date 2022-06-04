//
//  RegistrationViewController.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 25.05.2022.
//

import UIKit
import RxSwift
import RxCocoa

final class RegistrationViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registrationButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    private lazy var keyboardHelper = KeyboardHelper(scrollView: scrollView)
    private lazy var alertHelper = AlertsHelper(viewController: self)
    
    var viewModel: AuthViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureButtons()
        keyboardHelper.hideKeyboardGesture()
        configureRegistrationBindings()
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
    
    private func configureRegistrationBindings() {
        Observable
            .combineLatest(
                loginTextField.rx.text,
                passwordTextField.rx.text
            )
            .map { login, password in
                return !(login ?? "").isEmpty && (password ?? "").count >= 4
            }
            .bind(
                onNext: { [weak self] inputFilled in
                    self?.registrationButton?.isEnabled = inputFilled
                }
            )
            .disposed(by: disposeBag)
    }
    
    @objc func tapRegButton() {
        let action = UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            self?.viewModel?.back()
        }
        
        guard let isUserExist = viewModel?.registerUser(login: loginTextField.text ?? "",
                                                        password: passwordTextField.text ?? "")
        else {
            print("smth went wrong with view model")
            return
        }

        if isUserExist {
            alertHelper.showAlert(title: "Отлично",
                                  message: "Пароль был изменен!",
                                  externalAction: action)
        } else {
            alertHelper.showAlert(title: "Отлично",
                                  message: "Успешная регистрация",
                                  externalAction: action)
        }
    }
}
