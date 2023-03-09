//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Kirill Gontsov on 09.03.2023.
//

import UIKit

class AlertPresenter {
    
    let alertPresenterDelegate: MovieQuizViewController
    
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default, handler: { _ in alertModel.completion() })
        
        alert.addAction(action)
        alertPresenterDelegate.present(alert, animated: true)
    }
    
    init(alertPresenterDelegate: MovieQuizViewController) {
        self.alertPresenterDelegate = alertPresenterDelegate
    }
}