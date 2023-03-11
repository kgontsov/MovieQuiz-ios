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
    
    func comparisonRecords(gameResult: GameRecord) -> GameRecord {
        if gameResult.correct > self.correct {
            return gameResult
        } else {
            return self
        }
    }        
}
