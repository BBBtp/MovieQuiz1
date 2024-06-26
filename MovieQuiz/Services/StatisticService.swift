//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Богдан Топорин on 14.06.2024.
//

import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correct = "correct"
        case bestGame = "bestGame"
        case gamesCount = "gamesCount"
        case correctAnswers = "correctAnswers"
        case total = "total"
        case date = "date"
    }
}

extension StatisticService:StatisticServiceProtocol {
    
    private var correctAnswers: Int {
        get{
            return storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set{
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
   
    var totalAccuracy: Double {
        if gamesCount == 0 {
            return 0.0
        }
        else {
            return (Double(correctAnswers)/Double(10*gamesCount))*100
        }
    }
    
    var gamesCount: Int {
        get{
            let gamesCount = storage.integer(forKey: Keys.gamesCount.rawValue)
            return gamesCount
        }
        set{
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult{
        get{
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set{
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        gamesCount += 1
        if count > bestGame.correct{
            bestGame = GameResult(correct: count, total: amount, date: Date())
        }
        
    }
}
