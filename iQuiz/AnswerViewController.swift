// AnswerViewController.swift
import UIKit

final class AnswerViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    var quiz: Quiz?
    var questionIndex: Int = 0
    var correctCount: Int = 0
    var selectedIndex: Int = 0

    private var computedCorrectCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let quiz else { fatalError("quiz was not set before AnswerViewController loaded") }

        title = quiz.title
        showResult()

        addSwipeGestures()
        navigationItem.prompt = "Swipe right for next • Swipe left to quit"
    }

    private func showResult() {
        guard let quiz else { return }
        let q = quiz.questions[questionIndex]
        questionLabel.text = q.text

        let isCorrect = (selectedIndex == q.correctIndex)
        if isCorrect {
            resultLabel.text = "Correct"
            computedCorrectCount = correctCount + 1
        } else {
            resultLabel.text = "Incorrect"
            computedCorrectCount = correctCount
        }

        correctAnswerLabel.text = "Correct answer: \(q.answers[q.correctIndex])"
    }

    @IBAction func didTapNext(_ sender: Any) {
        guard let quiz else { return }

        let nextIndex = questionIndex + 1
        if nextIndex < quiz.questions.count {
            performSegue(withIdentifier: "AnswerToQuestion", sender: self)
        } else {
            performSegue(withIdentifier: "AnswerToFinished", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let quiz else { return }

        if segue.identifier == "AnswerToQuestion",
           let dest = segue.destination as? QuestionViewController {

            dest.quiz = quiz
            dest.questionIndex = questionIndex + 1
            dest.correctCount = computedCorrectCount
        }

        if segue.identifier == "AnswerToFinished",
           let dest = segue.destination as? FinishedViewController {

            dest.quizTitle = quiz.title
            dest.correctCount = computedCorrectCount
            dest.totalCount = quiz.questions.count
        }
    }

    private func addSwipeGestures() {
        let right = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        right.direction = .right
        view.addGestureRecognizer(right)

        let left = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        left.direction = .left
        view.addGestureRecognizer(left)
    }

    @objc private func handleSwipeRight() {
        didTapNext(self)
    }

    @objc private func handleSwipeLeft() {
        navigationController?.popToRootViewController(animated: true)
    }
}
