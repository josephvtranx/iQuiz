//
//  NetworkModels.swift
//  iQuiz
//
//  Created by Joseph Tran on 2/24/26.
//

import Foundation

// The JSON is an array of quizzes:
// [
//   { "title": "...", "desc": "...", "questions": [ { "text": "...", "answer": "...", "answers": [...] }, ... ] },
//   ...
// ]

struct NetworkQuiz: Decodable {
    let title: String
    let desc: String
    let questions: [NetworkQuestion]
}

struct NetworkQuestion: Decodable {
    let text: String
    let answer: String
    let answers: [String]
}
