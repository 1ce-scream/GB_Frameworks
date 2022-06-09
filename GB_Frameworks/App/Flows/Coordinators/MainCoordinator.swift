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
            let controller = storyboard.instantiateViewController(withIdentifier: "MapVC")
                as? MapViewController
        else { return }
        
        let viewModel = MapViewModel()
        viewModel.coordinator = self
        controller.viewModel = viewModel

        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }
    
    func showPhotoModule() {
        guard
            let controller = storyboard.instantiateViewController(withIdentifier: "PhotoVC")
                as? PhotoViewController
        else { return }
        
        let viewModel = PhotoViewModel()
        viewModel.coordinator = self
        controller.viewModel = viewModel
        
        rootController?.isNavigationBarHidden = true
        rootController?.pushViewController(controller, animated: true)
    }
    
    func showSelfieModule(photo: UIImage) {
        guard
            let controller = storyboard.instantiateViewController(withIdentifier: "SelfieVC")
                as? SelfieViewController
        else { return }
        
        let viewModel = PhotoViewModel()
        viewModel.coordinator = self
        controller.viewModel = viewModel
        controller.photo = photo
        
        rootController?.isNavigationBarHidden = true
        rootController?.pushViewController(controller, animated: true)

    }
    
    func backToMap() {
        rootController?.isNavigationBarHidden = false
        rootController?.popToRootViewController(animated: true)
    }
    
    func backToPhoto() {
        rootController?.popViewController(animated: true)
    }

    func showAuthModule() {
        self.onFinishFlow?()
    }
}
