//
//  AlertHelper.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 22.05.2022.
//

import UIKit

final class AlertsHelper {
    private var viewController: UIViewController?
    
    func showAlert(title: String, message: String, externalAction: UIAlertAction? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let standartAction = UIAlertAction(title: "OK",
                                           style: .cancel)
        
        if let action = externalAction {
            alert.addAction(action)
        } else {
            alert.addAction(standartAction)
        }
        
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}
