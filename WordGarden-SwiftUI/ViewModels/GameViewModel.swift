//
//  GameViewModel.swift
//  WordGarden-SwiftUI
//
//  Created by Theo Ntogiakos on 15/11/2023.
//

import SwiftUI
import AVFAudio

class GameViewModel: ObservableObject {
    @Published var gameData = GameData()
    @Published var displayWord = ""
    @Published var imageName = ""
    
    private var audioPlayer: AVAudioPlayer!
    private var currentWord = ""
    
    init() {
        self.currentWord = gameData.wordsToGuess[gameData.currentWordIndex]
        updateProgressImage()
        formatDisplayWord()
    }
    
    func play(clip name: String) {
        guard let audioClip = NSDataAsset(name: name) else {
            print("Coulnd't find \(name)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: audioClip.data)
            audioPlayer?.play()
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
    }
    
    func updateProgressImage() {
        // TODO: Refactor this so that it uses a plist for the list of images
        self.imageName = "wilt\(gameData.lives)"
        
        Task {
            try? await Task.sleep(nanoseconds: UInt64(0.75) * 1_000_000_000)
            await MainActor.run {
                self.imageName = "flower\(self.gameData.lives)"
            }
        }
    }
    
    func formatDisplayWord() {
        displayWord = ""
        for letter in currentWord {
            if gameData.guessedLetters.contains(letter) {
                displayWord += String(letter)
            } else {
                displayWord += "_"
            }
        }
    }
    
    func check(letter: String) {
        guard letter.trimmingCharacters(in: .whitespacesAndNewlines) != "" else { return }
        guard !gameData.guessedLetters.contains(letter) else { return }
        
        let lastLetter = letter.last!
        gameData.guessedLetters += String(lastLetter)
        if currentWord.contains(lastLetter) {
            gameData.correctGuesses += 1
            play(clip: "correct")
        } else {
            gameData.lives -= 1
            updateProgressImage()
            play(clip: "incorrect")
        }
        formatDisplayWord()
        isRoundFinished()
    }
    
    func isRoundFinished() {
        if !displayWord.contains("_") {
            gameData.gameState = .roundFinished(won: true, guesses: gameData.guessedLetters.count)
            gameData.wordsGuessed += 1
            play(clip: "word-guessed")
            gameData.currentWordIndex += 1
        } else if gameData.lives == 0 {
            gameData.gameState = .roundFinished(won: false, guesses: gameData.guessedLetters.count)
            gameData.wordsMissed += 1
            play(clip: "word-not-guessed")
            gameData.currentWordIndex += 1
        } else {
            gameData.gameState = .inPlay(guesses: gameData.guessedLetters.count, correct: gameData.correctGuesses)
            return
        }
        if gameData.currentWordIndex == gameData.wordsToGuess.count {
            gameData.gameState = .gameFinished
        }
    }
    
    func startGame() {
        guard gameData.currentWordIndex < gameData.wordsToGuess.count else { return }
        gameData.gameState = .start
        gameData.guessedLetters = ""
        gameData.correctGuesses = 0
        gameData.lives = 8
        currentWord = gameData.wordsToGuess[gameData.currentWordIndex]
        updateProgressImage()
        formatDisplayWord()
    }
}

enum GameState {
    case start
    case inPlay(guesses: Int, correct: Int)
    case roundFinished(won: Bool, guesses: Int)
    case gameFinished
    
    func getMessage() -> String {
        switch self {
        case .start:
            return "How Many Guesses to Uncover the Hidden Word?"
        case .inPlay(let guesses, let correct):
            return "You've had \(correct) correct out of \(guesses) \(guesses == 1 ? "guess" : "guesses") so far."
        case .roundFinished(let won, let guesses):
            if won {
                return "Well done! You guessed the word after \(guesses) guesses."
            } else {
                return "Oh no! You lost!"
            }
        case .gameFinished:
            return "That was the last word of the game."
        }
    }
    
    func starting() -> Bool {
        if case .start = self {
            return true
        }
        return false
    }
    
    func finished() -> Bool {
        if case .roundFinished = self {
            return true
        }
        return false
    }
}
