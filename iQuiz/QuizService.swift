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

        func decodeAndMap(_ data: Data) throws -> [Quiz] {
            let decoded = try JSONDecoder().decode([NetworkQuiz].self, from: data)

            return decoded.map { nq in
                Quiz(
                    title: nq.title,
                    desc: nq.desc,
                    questions: nq.questions.map { qq in
                        let idx = qq.answers.firstIndex(of: qq.answer) ?? 0
                        return Question(text: qq.text, answers: qq.answers, correctIndex: idx)
                    }
                )
            }
        }

        func tryLoadCacheOrFail(_ originalError: Error) {
            do {
                let cached = try QuizCache.loadRawJSON()
                let quizzes = try decodeAndMap(cached)
                DispatchQueue.main.async { completion(.success(quizzes)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(originalError)) }
            }
        }

        // If no network, use cache immediately
        guard isNetworkAvailable else {
            tryLoadCacheOrFail(FetchError.noNetwork)
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
            // Network error -> try cache
            if let error = error {
                tryLoadCacheOrFail(error)
                return
            }

            // Bad HTTP status -> try cache
            if let http = response as? HTTPURLResponse {
                print("STATUS:", http.statusCode)
                guard (200...299).contains(http.statusCode) else {
                    tryLoadCacheOrFail(FetchError.badStatus(http.statusCode))
                    return
                }
            }

            // No data -> try cache
            guard let data = data, !data.isEmpty else {
                tryLoadCacheOrFail(FetchError.emptyData)
                return
            }

            print("BYTES:", data.count)

            do {
                // Save raw JSON for offline use
                try QuizCache.save(rawJSON: data)

                // Decode + map
                let quizzes = try decodeAndMap(data)

                print("DECODED QUIZZES:", quizzes.count)
                DispatchQueue.main.async { completion(.success(quizzes)) }
            } catch {
                // Decode/save error -> try cache
                tryLoadCacheOrFail(error)
            }
        }.resume()
    }
}
