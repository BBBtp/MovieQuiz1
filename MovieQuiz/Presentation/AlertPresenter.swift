//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Богдан Топорин on 14.06.2024.
//

import Foundation
import UIKit

class AlertPresenter{
    weak var viewController: UIViewController?
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func presentAlert(model:AlertModel){
        let alertController = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = "Game result"
        let alertAction=UIAlertAction(title: model.buttonText, style: .default){_ in model.completion()}
        alertController.addAction(alertAction)
        viewController?.present(alertController, animated: true, completion: nil)
    }
}
