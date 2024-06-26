//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Богдан Топорин on 14.06.2024.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки    // 2
}
