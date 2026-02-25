//
//  QuizService.swift
//  iQuiz
//
//  Created by Joseph Tran on 2/24/26.
//
import Foundation
import Network

final class QuizService {

    static let shared = QuizService()

    private let monitor = NWPathMonitor()
    private var isMonitoring = false
    private var isNetworkAvailable: Bool = true

    private init() {}

    // Call once (e.g., in QuizListViewController.viewDidLoad)
    func startMonitoringNetwork() {
        guard !isMonitoring else { return }
        isMonitoring = true

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isNetworkAvailable = (path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    enum FetchError: Error {
        case noNetwork
        case invalidURL
        case badStatus(Int)
        case emptyData
    }

    func fetchQuizzes(completion: @escaping (Result<[Quiz], Error>) -> Void) {
        // Basic network check (required by rubric)
        guard isNetworkAvailable else {
            DispatchQueue.main.async { completion(.failure(FetchError.noNetwork)) }
            return
        }

        let urlString = AppSettings.quizURLString
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { completion(.failure(FetchError.invalidURL)) }
            return
        }

        print("FETCHING URL:", url.absoluteString)

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            if let http = response as? HTTPURLResponse {
                print("STATUS:", http.statusCode)
                guard (200...299).contains(http.statusCode) else {
                    DispatchQueue.main.async { completion(.failure(FetchError.badStatus(http.statusCode))) }
                    return
                }
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(FetchError.emptyData)) }
                return
            }

            print("BYTES:", data.count)

            do {
                let decoded = try JSONDecoder().decode([NetworkQuiz].self, from: data)
                print("DECODED QUIZZES:", decoded.count)

                let quizzes: [Quiz] = decoded.map { nq in
                    Quiz(
                        title: nq.title,
                        desc: nq.desc,
                        questions: nq.questions.map { qq in
                            let idx = qq.answers.firstIndex(of: qq.answer) ?? 0
                            return Question(text: qq.text, answers: qq.answers, correctIndex: idx)
                        }
                    )
                }

                print("MAPPED QUIZZES:", quizzes.count)
                DispatchQueue.main.async { completion(.success(quizzes)) }

            } catch {
                print("DECODE ERROR:", error)
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
