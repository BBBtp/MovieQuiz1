//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Богдан Топорин on 26.06.2024.
//

import XCTest
@testable import MovieQuiz
final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func noHiglightBorder() {
        
    }
    
    func show(quiz step: QuizStepViewModel) {
    
    }
    
    func show(quiz result: QuizResultsViewModel) {
    
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    
    }
    
    func showLoadingIndicator() {
    
    }
    
    func hideLoadingIndicator() {
    
    }
    
    func showNetworkError(message: String) {
    
    }
    
    func enableYesNoButtons() {
        
    }
    
    func disableYesNoButtons() {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emtyData = Data()
        let question = QuizQuestion(image: emtyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
        
        
    }
}
