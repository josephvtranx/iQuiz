// FinishedViewController.swift
import UIKit

final class FinishedViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    var quizTitle: String = ""
    var correctCount: Int = 0
    var totalCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        title = quizTitle
        scoreLabel.text = "\(correctCount) of \(totalCount) correct"

        if totalCount > 0 && correctCount == totalCount {
            titleLabel.text = "Perfect!"
        } else if totalCount > 0 && correctCount == totalCount - 1 {
            titleLabel.text = "Almost!"
        } else {
            titleLabel.text = "Nice try!"
        }

        addSwipeGestures()
        navigationItem.prompt = "Swipe left to quit"
    }

    @IBAction func didTapNext(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    private func addSwipeGestures() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        left.direction = .left
        view.addGestureRecognizer(left)
    }

    @objc private func handleSwipeLeft() {
        navigationController?.popToRootViewController(animated: true)
    }
}
