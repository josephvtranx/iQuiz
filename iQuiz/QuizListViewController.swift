// QuizListViewController.swift
import UIKit

final class QuizListViewController: UITableViewController {

    private let quizzes: [Quiz] = [
        Quiz(
            title: "Mathematics",
            desc: "Algebra, geometry, and quick math checks.",
            questions: [
                Question(text: "2 + 2 = ?", answers: ["3", "4", "5"], correctIndex: 1),
                Question(text: "5 × 3 = ?", answers: ["15", "8", "10"], correctIndex: 0)
            ]
        ),
        Quiz(
            title: "Marvel Super Heroes",
            desc: "Characters, powers, and story trivia.",
            questions: [
                Question(text: "Spider Man is from:", answers: ["DC", "Marvel"], correctIndex: 1),
                Question(text: "Thor's weapon is:", answers: ["Mjolnir", "Shield", "Ring"], correctIndex: 0)
            ]
        ),
        Quiz(
            title: "Science",
            desc: "Physics, chemistry, and basic biology.",
            questions: [
                Question(text: "Water's chemical formula is:", answers: ["H2O", "CO2", "NaCl"], correctIndex: 0),
                Question(text: "The Earth orbits the:", answers: ["Moon", "Sun"], correctIndex: 1)
            ]
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "iQuiz"
        tableView.rowHeight = 72

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Settings",
            style: .plain,
            target: self,
            action: #selector(didTapSettings)
        )
    }

    @objc private func didTapSettings() {
        let alert = UIAlertController(
            title: "Settings",
            message: "Settings go here",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        quizzes.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "TopicCell")

        let quiz = quizzes[indexPath.row]
        cell.textLabel?.text = quiz.title
        cell.detailTextLabel?.text = quiz.desc
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.imageView?.image = UIImage(systemName: "questionmark.circle")
        cell.imageView?.tintColor = .label
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ListToQuestion" else { return }
        guard let dest = segue.destination as? QuestionViewController else { return }
        guard let cell = sender as? UITableViewCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        dest.quiz = quizzes[indexPath.row]
        dest.questionIndex = 0
        dest.correctCount = 0
    }
}
