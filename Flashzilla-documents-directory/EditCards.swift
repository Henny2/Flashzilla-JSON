//
//  EditCards.swift
//  Flashzilla
//
//  Created by Henrieke Baunack on 4/4/24.
//

import SwiftUI

struct EditCards: View {
    @Environment(\.dismiss) var dismiss

    @State private var cards = [Card]()
    @State private var newPrompt = ""
    @State private var newAnswer = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("Add new card") {
                    TextField("Prompt", text: $newPrompt)
                    TextField("Answer", text: $newAnswer)
                    Button("Add Card", action: addCard)
                }
                Section {
                    ForEach(0..<cards.count, id: \.self) { index in
                        VStack {
                            Text(cards[index].prompt)
                                .font(.headline)
                            Text(cards[index].answer)
                                .foregroundStyle(.secondary)
                        }
                        
                    }
                    .onDelete(perform: removeCards)
                }
            }
            .navigationTitle("Edit Cards")
            .toolbar {
                Button("Done", action: done)
            }
            .onAppear(perform: loadData)
        }
    }
    
    func done() {
        dismiss()
    }
    
    func loadData(){
        let url = URL.documentsDirectory.appending(path: "cards.txt")
        do {
            let data = try Data(contentsOf: url)
            if let decoded = try? JSONDecoder().decode([Card].self, from: data){
                cards = decoded
            }
        }
        catch {
            print("there was an error reading from the documents directory")
        }
    }
    
    //https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    
    func saveData() {
        let url = URL.documentsDirectory.appending(path: "cards.txt")
        if let data = try? JSONEncoder().encode(cards){
//            UserDefaults.standard.setValue(data, forKey: "Cards")
            do {
                try data.write(to: url, options: [.atomic, .completeFileProtection])
            } catch {
                print("there was an error trying to write to documents directory")
            }
            
        }
    }
    
    func addCard() {
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
        guard trimmedPrompt.isEmpty == false && trimmedAnswer.isEmpty == false else {return}
        let card = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        cards.insert(card, at: 0)
        saveData()
        newPrompt = ""
        newAnswer = ""
    }
    
    func removeCards(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        saveData()
    }
}

#Preview {
    EditCards()
}

