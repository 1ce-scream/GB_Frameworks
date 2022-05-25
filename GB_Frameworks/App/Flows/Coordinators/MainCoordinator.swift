//
//  MainCoordinator.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 25.05.2022.
//

import UIKit

final class MainCoordinator: BaseCoordinator {
    var rootController: UINavigationController?
    var onFinishFlow: (() -> Void)?

    override func start() {
        showMapModule(viewModel: MapViewModel())
    }

    private func showMapModule(viewModel: MapViewModel) {
        guard
            let controller = storyboard
                .instantiateViewController(withIdentifier: "MapVC")
                as? MapViewController
        else { return }
        
        controller.viewModel = viewModel
        
        controller.onLogin = { [weak self] in
            self?.showAuthModule()
            self?.onFinishFlow?()
        }

        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }

    private func showAuthModule() {
        let coordinator = AuthCoordinator()
        coordinator.start()
    }
}
