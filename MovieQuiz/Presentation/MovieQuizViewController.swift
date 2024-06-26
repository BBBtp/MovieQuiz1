import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol{
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    //MARK: - Lifestyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
           
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    
    
    //MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: BounceButton) {
        presenter.noButtonClicked()
    }
    

    @IBAction private func yesButtonClicked(_ sender: BounceButton) {
        presenter.yesButtonClicked()
    }
    
    //MARK: - Public functions
    
    func highlightImageBorder(isCorrectAnswer:Bool){
        imageView.layer.masksToBounds = true // 1
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrectAnswer == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            presenter.didAnswer(isCorrectAnswer: isCorrectAnswer)
        }
        else{
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
    }
    func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз"){
            [weak self] in
            guard let self = self else {return}
            self.presenter.restartGame()
            
        }
        alertPresenter.show(in: self, model: alertModel)
        
    }
    
    
    func noHiglightBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        
        message = presenter.makeResultsMessage()

        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.presenter.restartGame()
        }

        alertPresenter.show(in: self, model: model)
    }
    
     func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
     }
    func enableYesNoButtons() {
            btnYes.isEnabled = true
            btnNo.isEnabled = true
        }

    func disableYesNoButtons() {
            btnYes.isEnabled = false
            btnNo.isEnabled = false
        }
}
