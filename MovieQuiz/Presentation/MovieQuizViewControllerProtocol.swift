//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Богдан Топорин on 26.06.2024.
//

import Foundation
import UIKit
protocol MovieQuizViewControllerProtocol: AnyObject {
    func enableYesNoButtons()
    func disableYesNoButtons()
    
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func noHiglightBorder()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
} 
