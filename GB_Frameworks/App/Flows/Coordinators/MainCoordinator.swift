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
        showMapModule()
    }

    private func showMapModule() {
        guard
            let controller = storyboard
                .instantiateViewController(withIdentifier: "MapVC")
                as? MapViewController
        else { return }
        
        let viewModel = MapViewModel()
        viewModel.coordinator = self
        controller.viewModel = viewModel

        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }

    func showAuthModule() {
        self.onFinishFlow?()
    }
}
