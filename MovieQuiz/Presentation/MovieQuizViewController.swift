import UIKit

final class MovieQuizViewController: UIViewController,QuestionFactoryDelegate{
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    
    
    private var statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactory?
    
    private var alertPresenter = AlertPresenter()
    private let presenter = MovieQuizPresenter()
    
    //MARK: - Lifestyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
           
           imageView.layer.cornerRadius = 20
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            statisticService = StatisticService()
            showLoadingIndicator()
            questionFactory?.loadData()
        presenter.viewController = self
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didRecieveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
        
    }
    
    //MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    //MARK: - Private functions
    
    private func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз"){
            [weak self] in
            guard let self = self else {return}
            self.presenter.restartGame()
            self.questionFactory?.requestNextQuestion()
            
        }
        alertPresenter.show(in: self, model: alertModel)
        
    }
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true // 1
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            presenter.didAnswer(isCorrectAnswer: isCorrect)
        }
        else{
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.presenter.questionFactory = self.questionFactory
                    self.presenter.showNextQuestionOrResults()
                    self.imageView.layer.borderWidth = 0
                    self.imageView.layer.borderColor = nil
                }
    }
    
    private func showNextQuestionOrResults() {
        presenter.showNextQuestionOrResults()
    }
    //результаты
    func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)

            let bestGame = statisticService.bestGame

            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(presenter.correctAnswers)\\\(presenter.questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

            let resultMessage = [
                currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")

            message = resultMessage
        }

        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.presenter.restartGame()

            self.questionFactory?.requestNextQuestion()
        }

        alertPresenter.show(in: self, model: model)
    }
    
     func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
     }

}
