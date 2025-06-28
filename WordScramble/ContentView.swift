//
//  ContentView.swift
//  WordScramble
//
//  Created by Deepak Kumar Behera on 27/05/25.
//

import SwiftUI

struct ContentView: View {
    let people = ["Finn", "Leia", "Luke", "Rey"]
    @State private var usedWord = [String]()
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    @State private var showingError: Bool = false
    @State private var score: Int = 0
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count >= 3 else {
            showingError = true
            wordError(title: "Word is less then 3 letter", message: "Please make it more than 3 character")
            return}
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        withAnimation {
            usedWord.insert(answer, at: 0)
            score+=1
        }
        newWord = ""
        
    }
    func startGame() {
        if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWord = try? String(contentsOf: startWordUrl, encoding: .ascii) {
                let allword = startWord.components(separatedBy: "\n")
                rootWord = allword.randomElement() ?? "silkworm"
                score = 0
                return
            }
        }
        fatalError("Can't find the start.txt file")
    }
    func isOriginal(word: String) -> Bool {
        !usedWord.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
                print(tempWord)
            } else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWord, id: \.self) { word in
                        HStack {
                            Text("\(word)")
                            Spacer()
                            Image(systemName: "\(word.count).circle")
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addNewWord()
            }
            .onAppear {
                startGame()
            }
            .alert(errorTitle, isPresented: $showingError) {
                Button("ok") {
                    showingError = false
                }
            }message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItemGroup {
                    Button("Next", role: .destructive) {
                        startGame()
                        withAnimation {
                            usedWord.removeAll()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .foregroundStyle(.white)
                    Spacer()
                    Text("Score: \(score)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
