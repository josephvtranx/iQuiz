import UIKit

final class QuizListViewController: UITableViewController {

    private var quizzes: [Quiz] = [
        Quiz(title: "Mathematics", desc: "Algebra, geometry, and quick math checks.", questions: []),
        Quiz(title: "Marvel Super Heroes", desc: "Characters, powers, and story trivia.", questions: []),
        Quiz(title: "Science", desc: "Physics, chemistry, and basic biology.", questions: [])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        QuizService.shared.startMonitoringNetwork()

        // Pull to refresh (extra credit)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        // Initial fetch
        fetchAndReload(showAlertOnFailure: true)
    }

    @objc private func didPullToRefresh() {
        fetchAndReload(showAlertOnFailure: false)
    }

    private func fetchAndReload(showAlertOnFailure: Bool) {
        QuizService.shared.fetchQuizzes { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()

                switch result {
                case .success(let downloaded):
                    if !downloaded.isEmpty {
                        self.quizzes = downloaded
                        self.tableView.reloadData()
                    }

                case .failure(let error):
                    if showAlertOnFailure {
                        self.showNetworkAlert(error: error)
                    }
                    print("FETCH ERROR:", error)
                }
            }
        }
    }

    private func showNetworkAlert(error: Error) {
        let ac = UIAlertController(
            title: "Network Error",
            message: "Could not download quizzes. Check your connection and URL in Settings.",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    // MARK: - Settings Button
    @IBAction func didTapSettings(_ sender: Any) {
        performSegue(withIdentifier: "ShowSettings", sender: nil)
    }

    // MARK: - Table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        quizzes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let quiz = quizzes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath)

        var config = cell.defaultContentConfiguration()
        config.text = quiz.title
        config.secondaryText = quiz.desc
        config.image = UIImage(systemName: "questionmark.circle")

        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ListToQuestion",
           let indexPath = tableView.indexPathForSelectedRow,
           let dest = segue.destination as? QuestionViewController {
            dest.quiz = quizzes[indexPath.row]
        }
    }
}
