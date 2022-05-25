//
//  BaseCoordinator.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 25.05.2022.
//

import UIKit

class BaseCoordinator {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var childCoordinators: [BaseCoordinator] = []
    
    func start() {
        // Переопределяется в наследниках
    }
    
    func addDependency(_ coordinator: BaseCoordinator) {
        for element in childCoordinators where element === coordinator {
            return
        }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: BaseCoordinator?) {
        guard
            childCoordinators.isEmpty == false,
            let coordinator = coordinator
        else {
            return
        }

        for (index, element) in childCoordinators.reversed().enumerated() where
            element === coordinator
        {
            childCoordinators.remove(at: index)
            break
        }
    }
    
    func setAsRoot(_ controller: UIViewController) {
        if #available(iOS 13, *) {
            let sceneDelegate =
            UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            
            sceneDelegate?.window?.rootViewController = controller
        } else {
            UIApplication.shared.keyWindow?.rootViewController = controller
        }
    }
}
