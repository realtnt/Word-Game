//
//  GameData.swift
//  WordGarden-SwiftUI
//
//  Created by Theo Ntogiakos on 15/11/2023.
//

import Foundation

struct GameData {
    var gameState = GameState.start
    var wordsGuessed = 0
    var wordsMissed = 0
    var currentWordIndex = 0
    var wordsToGuess = [String]()
    var correctGuesses = 0
    var guessedLetters = ""
    var gameStatusMessage: String { gameState.getMessage() }
    var lives = 8
    
    init() {
        // TODO: Create and use an API to return an array of words
        wordsToGuess = ["SWIFT", "DOG", "MOUSE"]
        
    }
}
