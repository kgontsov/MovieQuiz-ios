import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate  {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers: Int = 0
    
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
       imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()

        showLoadingIndicator()
        questionFactory?.loadData()
        
        alertPresenter = AlertPresenter(alertPresenterDelegate: self)
    }
    
    // MARK: - QuestionFactoryDelegate

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
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        noButton.isEnabled = false
        yesButton.isEnabled = false
        if isCorrect {
            correctAnswers += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
           statisticService.store(correct: self.correctAnswers, total: presenter.questionsAmount)
           let resultAlert = AlertModel(
                                 title: "Этот раунд окончен",
                                 message: "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\n Количество сыгранных квизов: \(statisticService.gamesCount)\n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%",
                                 buttonText: "Сыграть еще раз")
                                 { [weak self] in
                                     guard let self = self else { return }

                                     self.presenter.resetQuestionIndex()
                                     self.correctAnswers = 0

                                     self.questionFactory?.requestNextQuestion()
                                 }
           imageView.layer.borderWidth = 0

           alertPresenter?.show(alertModel: resultAlert)
       } else {
           presenter.switchToNextQuestion()
           imageView.layer.borderWidth = 0

           questionFactory?.requestNextQuestion()
       }
     }
    
    private func showLoadingIndicator() {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
        }
        
    private func hideLoadingIndicator() {
            activityIndicator.stopAnimating()
        }

    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertError = AlertModel(title: "Ошибка",
                               message: "Проверьте соединение с интернетом",
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(alertModel: alertError)
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
}

