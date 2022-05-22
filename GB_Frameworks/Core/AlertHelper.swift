//
//  AlertHelper.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 22.05.2022.
//

import UIKit

class AlertsHelper {
    private var viewController: UIViewController?
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "OK",
            style: .cancel)
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}
