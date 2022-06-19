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
        showLoginModule()
    }
    
    func showLoginModule() {
        guard
            let controller = storyboard
                .instantiateViewController(withIdentifier: "LoginVC")
                as? LoginViewController
        else { return }
        
        let viewModel = AuthViewModel()
        viewModel.coordinator = self
        controller.viewModel = viewModel
        
        let rootController = UINavigationController(rootViewController: controller)
        
        setAsRoot(rootController)
        self.rootController = rootController
        
    }
    
    func showRegisterModule() {
        guard
            let controller = storyboard
                .instantiateViewController(withIdentifier: "RegistrationVC")
                as? RegistrationViewController
        else { return }
        
        lazy var viewModel = AuthViewModel()
        viewModel.coordinator = self
        controller.viewModel = viewModel
        
        rootController?.pushViewController(controller, animated: true)
    }
    
    func showMainModule() {
        self.onFinishFlow?()
    }
    
    func backToLogin() {
        self.rootController?.popViewController(animated: true)
    }
}
