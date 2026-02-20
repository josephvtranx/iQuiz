//
//  QuizModels.swift
//  iQuiz
//
//  Created by Joseph Tran on 2/19/26.
//

import Foundation

struct Quiz {
    let title: String
    let desc: String
    let questions: [Question]
}

struct Question {
    let text: String
    let answers: [String]
    let correctIndex: Int
}
