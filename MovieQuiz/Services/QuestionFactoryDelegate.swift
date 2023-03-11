//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Kirill Gontsov on 09.03.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error) 
}
