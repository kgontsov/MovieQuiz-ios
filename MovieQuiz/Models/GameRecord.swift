//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Kirill Gontsov on 09.03.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func newRecord (new game: GameRecord) -> Bool {
        correct < game.correct
    }
}
