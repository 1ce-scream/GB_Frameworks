//
//  AuthCoordinator.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 25.05.2022.
//

import UIKit

final class AuthCoordinator: BaseCoordinator {
    var rootController: UINavigationController?
    var onFinishFlow: (() -> Void)?
    
    override func start() {
        showLoginModule(viewModel: LoginViewModel())
    }
    
    private func showLoginModule(viewModel: LoginViewModel) {
        guard
            let controller = storyboard
                .instantiateViewController(withIdentifier: "LoginVC")
                as? LoginViewController
        else { return }
        
        controller.onRegister = { [weak self] in
            self?.showRegisterModule(viewModel: LoginViewModel())
        }
        
        controller.onLogin = { [weak self] in
            self?.onFinishFlow?()
        }
        
        controller.viewModel = viewModel
        
        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }
    
    private func showRegisterModule(viewModel: LoginViewModel) {
        guard
            let controller = storyboard
                .instantiateViewController(withIdentifier: "RegistrationVC")
                as? RegistrationViewController
        else { return }
        
        controller.viewModel = viewModel
        
        controller.onLogin = { [weak self] in
            self?.backToLogin()
            self?.onFinishFlow?()
        }
        
        rootController?.pushViewController(controller, animated: true)
    }
    
    private func backToLogin() {
        rootController?.popViewController(animated: true)
    }
}
