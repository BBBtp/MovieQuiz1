import UIKit

final class MovieQuizViewController: UIViewController,QuestionFactoryDelegate{
    //Лейбл для вопроса
    @IBOutlet private var textLabel: UILabel!
    //Картинка фильма
    @IBOutlet private var imageView: UIImageView!
    //Счетчик вопросов
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    //Переменная для хранения количества отвеченных вопросов
    private var currentQuestionIndex = 0
    private var statisticService: StatisticServiceProtocol!
    //Переменная для правильных ответов
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter!
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
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
            self.currentQuestionIndex = 0
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
      if currentQuestionIndex == questionsAmount - 1 { // 1
          statisticService.store(correct: correctAnswers, total: currentQuestionIndex+1)
          let bestGame = statisticService.bestGame
          let result = QuizResultsViewModel(title: "Раунд окончен", text: "Ваш результат: \(correctAnswers)/\(currentQuestionIndex+1)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\n Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%", buttonText: "Сыграть еще раз")
          show(quiz: result)
      }
      else { // 2
        currentQuestionIndex += 1
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
                        self.currentQuestionIndex = 0
                        self.correctAnswers = 0
                        self.questionFactory?.requestNextQuestion()
                        self.btnYes.isEnabled = true
                        self.btnNo.isEnabled = true
        }
        alertPresenter.presentAlert(model: alertModel)
    }
    
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
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
}

    override func viewDidLoad() {
        super.viewDidLoad()
           
           imageView.layer.cornerRadius = 20
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            statisticService = StatisticService()

            showLoadingIndicator()
            questionFactory?.loadData()
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
