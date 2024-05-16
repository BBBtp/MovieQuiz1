import UIKit

final class MovieQuizViewController: UIViewController {
    //Лейбл для вопроса
    @IBOutlet private var textLabel: UILabel!
    //Картинка фильма
    @IBOutlet private var imageView: UIImageView!
    //Счетчик вопросов
    @IBOutlet private var counterLabel: UILabel!
    //Переменная для хранения количества отвеченных вопросов
    private var currentQuestionIndex = 0
    //Переменная для правильных ответов
    private var correctAnswers = 0
    // вью модель для состояния "Вопрос показан"
    struct QuizStepViewModel {
      // картинка с афишей фильма с типом UIImage
      let image: UIImage
      // вопрос о рейтинге квиза
      let question: String
      // строка с порядковым номером этого вопроса (ex. "1/10")
      let questionNumber: String
    }
    //Структура для мок данных
    struct QuizQuestion {
      // строка с названием фильма,
      // совпадает с названием картинки афиши фильма в Assets
      let image: String
      // строка с вопросом о рейтинге фильма
      let text: String
      // булевое значение (true, false), правильный ответ на вопрос
        var correctAnswer: Bool
    }
    // для состояния "Результат квиза"
    struct QuizResultsViewModel {
      // строка с заголовком алерта
      let title: String
      // строка с текстом о количестве набранных очков
      let text: String
      // текст для кнопки алерта
      let buttonText: String
    }
    // массив вопросов
    private let questions: [QuizQuestion] = [
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
        ]
    //окно по центру
    //Красит рамку картинки и результат
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true // 1
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 6
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            
        }
        else{
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
           self.showNextQuestionOrResults()
        }
    }
    //Следующий вопрос
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questions.count - 1 { // 1
          let result = QuizResultsViewModel(title: "Раунд окончен", text: "Ваш результат: \(correctAnswers)", buttonText: "Сыграть еще раз")
          show(quiz: result)
      }
      else { // 2
        currentQuestionIndex += 1
                  let nextQuestion = questions[currentQuestionIndex]
                  let viewModel = convert(model: nextQuestion)
                  
                  show(quiz: viewModel)
      }
    }
    //результаты
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        if questions[currentQuestionIndex].correctAnswer == false {
            showAnswerResult(isCorrect: true)
            correctAnswers+=1
        }
        else{
            showAnswerResult(isCorrect: false)
            
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        if questions[currentQuestionIndex].correctAnswer == true {
            showAnswerResult(isCorrect: true)
            correctAnswers+=1
        }
        else{
            showAnswerResult(isCorrect: false)
            
        }
    }
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel( // 1
            image: UIImage(named: model.image) ?? UIImage(), // 2
            question: model.text, // 3
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)") // 4
        return questionStep
    }
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
}

    override func viewDidLoad() {
        super.viewDidLoad()
        show(quiz: convert(model: questions[0]))
    }
    
}
