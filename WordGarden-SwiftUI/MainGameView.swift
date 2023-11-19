//
//  ContentView.swift
//  WordGarden-SwiftUI
//
//  Created by Theo Ntogiakos on 15/11/2023.
//

import SwiftUI

struct MainGameView: View {
    @StateObject var viewModel = GameViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                GameInfoView(viewModel: viewModel)

                Spacer()
                Text(viewModel.gameData.gameStatusMessage)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(height: 80)
                    .minimumScaleFactor(0.5)
                    .padding()
                
                Text(viewModel.displayWord)
                    .kerning(5)
                    .font(.title)

                switch viewModel.gameData.gameState {
                case .roundFinished:
                    Button("Another Word?") {
                        viewModel.startGame()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.mint)
                case .gameFinished:
                    Button("Play Again?") {
                        viewModel.gameData.currentWordIndex = 0
                        viewModel.startGame()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                default:
                    LetterInputView(viewModel: viewModel)
                }
                    
                Spacer()

                Image(viewModel.imageName)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea(edges: .bottom)
                    .animation(.easeIn(duration: 0.75), value: viewModel.imageName)
            }
        }
    }
}

#Preview {
    MainGameView()
}

struct LetterInputView: View {
    @State private var guessedLetter: String = ""
    @FocusState private var textFieldIsFocused: Bool
    var viewModel: GameViewModel

    var body: some View {
        HStack {
            TextField("", text: $guessedLetter)
                .textFieldStyle(.roundedBorder)
                .frame(width: 30)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray, lineWidth: 2)
                }
                .keyboardType(.asciiCapable)
                .submitLabel(.done)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
                .onChange(of: guessedLetter) {
                    guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                    guard let lastLetter = guessedLetter.last else { return }
                    guessedLetter = String(lastLetter).uppercased()
                }
                .focused($textFieldIsFocused)
                .onSubmit {
                    guard guessedLetter != "" else { return }
                    viewModel.check(letter: guessedLetter)
                    guessedLetter = ""
                }
                .onAppear {
                    textFieldIsFocused = true
                }
            
            Button("Guess a letter") {
                viewModel.check(letter: guessedLetter)
                guessedLetter = ""
            }
            .buttonStyle(.bordered)
            .tint(.mint)
            .disabled(guessedLetter.isEmpty)
        }
    }
}

struct GameInfoView: View {
    var viewModel: GameViewModel
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Words Guessed: \(viewModel.gameData.wordsGuessed)")
                Text("Words Missed: \(viewModel.gameData.wordsMissed)")
            }
            Spacer()
            VStack(alignment: .trailing) {
                let wordsLeftToGuess = viewModel.gameData.wordsToGuess.count - (viewModel.gameData.wordsGuessed + viewModel.gameData.wordsMissed)
                Text("Words to Guess: \(wordsLeftToGuess)")
                Text("Words in Game: \(viewModel.gameData.wordsToGuess.count)")
            }
        }
        .padding(.horizontal)
        .font(.subheadline)
    }
}
