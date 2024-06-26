//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Богдан Топорин on 26.06.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    weak var questionFactory: QuestionFactory?
    var statisticService: StatisticServiceProtocol!
    //MARK: - Public functions
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
            QuizStepViewModel(
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)" // ОШИБКА: `currentQuestionIndex` и `questionsAmount` неопределены
            )
        }
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
    func restartGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
        }
        
    func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
            }
        }
    
    func showNextQuestionOrResults() {
            if self.isLastQuestion() {
                let text = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
                
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                    viewController?.show(quiz: viewModel)
            } else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion()
                viewController?.btnYes.isEnabled = true
                viewController?.btnNo.isEnabled = true
            }
        }

    func didAnswer (isCorrectAnswer: Bool){
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    //MARK: - Private functions
    
    private func didAnswer (isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        if currentQuestion.correctAnswer == givenAnswer {
            viewController?.showAnswerResult(isCorrect: true)
            viewController?.btnNo.isEnabled = false
            viewController?.btnYes.isEnabled = false
        }
        else{
            viewController?.showAnswerResult(isCorrect: false)
            viewController?.btnNo.isEnabled = false
            viewController?.btnYes.isEnabled = false
        }
    }
}
