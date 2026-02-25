//
//  QuizCache.swift
//  iQuiz
//
//  Created by Joseph Tran on 2/24/26.
//

import Foundation

enum QuizCache {

    private static let fileName = "quizzes.json"

    private static var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(fileName)
    }

    static func save(rawJSON data: Data) throws {
        try data.write(to: fileURL, options: [.atomic])
    }

    static func loadRawJSON() throws -> Data {
        try Data(contentsOf: fileURL)
    }

    static func exists() -> Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }
}
