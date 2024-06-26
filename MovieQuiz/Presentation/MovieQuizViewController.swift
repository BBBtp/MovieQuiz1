import UIKit

final class MovieQuizViewController: UIViewController,QuestionFactoryDelegate{
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    
    
    private var statisticService: StatisticServiceProtocol!
    private var correctAnswers = 0
    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter!
    private let presenter = MovieQuizPresenter()
    
    //MARK: - Lifestyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
           
           imageView.layer.cornerRadius = 20
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            statisticService = StatisticService()
            showLoadingIndicator()
            questionFactory?.loadData()
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
        
    }
    
    //MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        if currentQuestion.correctAnswer == false {
            showAnswerResult(isCorrect: true)
            correctAnswers+=1
            btnNo.isEnabled = false
        }
        else{
            showAnswerResult(isCorrect: false)
            btnNo.isEnabled = false
            
        }
    }
    

    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        if currentQuestion.correctAnswer == true {
            showAnswerResult(isCorrect: true)
            correctAnswers+=1
            btnYes.isEnabled = false
            
        }
        else{
            showAnswerResult(isCorrect: false)
            btnYes.isEnabled = false
            
        }
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
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
            
        }
        alertPresenter.presentAlert(model: alertModel)
        
    }
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true // 1
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            
        }
        else{
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self]  in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            self.showNextQuestionOrResults()
        }
    }
    //Следующий вопрос
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
          let bestGame = statisticService.bestGame
            let result = QuizResultsViewModel(title: "Раунд окончен", text: "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\n Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%", buttonText: "Сыграть еще раз")
          show(quiz: result)
      }
      else {
          presenter.switchToNextQuestion()
          questionFactory?.requestNextQuestion()
              btnNo.isEnabled = true
              btnYes.isEnabled = true
              
          }
      
    }
    //результаты
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText){
            [weak self] in
                        guard let self = self else { return }
                        self.presenter.resetQuestionIndex()
                        self.correctAnswers = 0
                        self.questionFactory?.requestNextQuestion()
                        self.btnYes.isEnabled = true
                        self.btnNo.isEnabled = true
        }
        alertPresenter.presentAlert(model: alertModel)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
}

}
