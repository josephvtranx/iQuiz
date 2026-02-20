// QuestionViewController.swift
import UIKit

final class QuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!

    var quiz: Quiz?
    var questionIndex: Int = 0
    var correctCount: Int = 0

    private var selectedIndex: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        guard quiz != nil else { fatalError("quiz was not set before QuestionViewController loaded") }

        tableView.dataSource = self
        tableView.delegate = self

        title = quiz!.title
        loadQuestion()

        addSwipeGestures()
        navigationItem.prompt = "Swipe right to submit • Swipe left to quit"
    }

    private func loadQuestion() {
        guard let quiz else { return }
        let q = quiz.questions[questionIndex]
        questionLabel.text = q.text
        selectedIndex = nil
        tableView.reloadData()
    }

    @IBAction func didTapSubmit(_ sender: Any) {
        guard selectedIndex != nil else { return }
        performSegue(withIdentifier: "QuestionToAnswer", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "QuestionToAnswer" else { return }
        guard let dest = segue.destination as? AnswerViewController else { return }
        guard let quiz else { return }
        guard let selectedIndex else { return }

        dest.quiz = quiz
        dest.questionIndex = questionIndex
        dest.correctCount = correctCount
        dest.selectedIndex = selectedIndex
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let quiz else { return 0 }
        return quiz.questions[questionIndex].answers.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerChoiceCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "AnswerChoiceCell")

        guard let quiz else { return cell }
        cell.textLabel?.text = quiz.questions[questionIndex].answers[indexPath.row]
        cell.accessoryType = (indexPath.row == selectedIndex) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
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
        didTapSubmit(self)
    }

    @objc private func handleSwipeLeft() {
        navigationController?.popToRootViewController(animated: true)
    }
}
