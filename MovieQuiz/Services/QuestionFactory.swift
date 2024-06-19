//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Богдан Топорин on 14.06.2024.
//

import Foundation
class QuestionFactory: QuestionFactoryProtocol{
    private let moviesLoader: MoviesLoading
    private var questionFactory: QuestionFactoryProtocol?
    weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
            self.moviesLoader = moviesLoader
            self.delegate = delegate
        }
    /*private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]*/
    func loadData() {
        
        moviesLoader.loadMovies{
            [weak self] result in
            DispatchQueue.global().async {
                guard let self = self else {return}
                switch result{
                case .success(let mostPolularMovies):
                    self.movies = mostPolularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                    }
                }
            }
       }
    func requestNextQuestion() {
        DispatchQueue.global().async {
            [weak self] in
            guard let self = self else {return}
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return}
            
            var imageData = Data()
            do{
                imageData = try Data(contentsOf: movie.resizedImageURL)
                print("Удалось загрузить картинку")
            }
            catch{
                print("Не удалось загрузить картинку")
                }
            let rating = Float(movie.rating) ?? 0
            let textrating = (4...9).randomElement() ?? 0
            let text = "Рейтинг этого фильма больше \(textrating) ?"
            let correctAnswer = rating > Float(textrating)
            let question = QuizQuestion (image: imageData, text: text, correctAnswer: correctAnswer)
            DispatchQueue.main.async {
                [weak self] in
                guard let self = self else {return}
                self.delegate?.didReceiveNextQuestion(question: question)
                }
            }
        }
}
