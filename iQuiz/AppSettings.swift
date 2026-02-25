import Foundation

enum AppSettings {
    static let urlKey = "quiz_url"
    static let defaultQuizURL = "http://tednewardsandbox.site44.com/questions.json"

    static var quizURLString: String {
        get { UserDefaults.standard.string(forKey: urlKey) ?? defaultQuizURL }
        set { UserDefaults.standard.set(newValue, forKey: urlKey) }
    }

    static func normalizedURLString(_ input: String) -> String {
        var s = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return defaultQuizURL }

        if s.hasPrefix("http://") {
            s = "https://" + s.dropFirst("http://".count)
        } else if !s.hasPrefix("https://") {
            s = "https://" + s
        }
        return s
    }
}
