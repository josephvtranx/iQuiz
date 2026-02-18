import UIKit

struct QuizTopic {
    let title: String
    let desc: String
    let icon: UIImage?
}

final class QuizListViewController: UITableViewController {

    private let topics: [QuizTopic] = [
        QuizTopic(title: "Mathematics",
                  desc: "Algebra, geometry, and quick math checks.",
                  icon: UIImage(systemName: "function")),
        QuizTopic(title: "Marvel Super Heroes",
                  desc: "Characters, powers, and story trivia.",
                  icon: UIImage(systemName: "bolt.fill")),
        QuizTopic(title: "Science",
                  desc: "Physics, chemistry, and basic biology.",
                  icon: UIImage(systemName: "atom"))
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        topics.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "TopicCell")

        let topic = topics[indexPath.row]
        cell.textLabel?.text = topic.title
        cell.detailTextLabel?.text = topic.desc
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.imageView?.image = topic.icon
        cell.imageView?.tintColor = .label
        return cell
    }
}
