import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: ResultAlertPresenter?
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        alertPresenter = ResultAlertPresenter(alertPresenterDelegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        
        showLoadingIndicator()
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Methods
    
    func show(quiz step: QuizStepViewModel) {
        self.imageView.image = step.image
        self.textLabel.text = step.question
        self.counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else {
                    return
                }
                self.presenter.restartGame()
            }
        alertPresenter?.showAlert(with: alert)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        changeButtonsAccess(isEnable: false)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModal = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alertPresenter?.showAlert(with: alertModal)
    }
    
    func hideImageBorder() {
        imageView.layer.borderWidth = 0
        
        changeButtonsAccess(isEnable: true)
    }
    
    private func changeButtonsAccess(isEnable: Bool) {
        yesButton.isEnabled = isEnable ? true : false
        noButton.isEnabled = isEnable ? true : false
    }
}

