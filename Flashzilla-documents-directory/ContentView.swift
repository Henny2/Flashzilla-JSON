//
//  ContentView.swift
//  Flashzilla
//
//  Created by Henrieke Baunack on 3/9/24.
//

import SwiftUI

extension View {
    // total: total card count
    // position: position in the stack
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total-position)
        // 10 points down per card in the stack
        return self.offset(y: offset * 10)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor  // for red green blindness
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    @State private var cards = Array<Card>()
    
    @State private var showingEditScreen = false
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // a timer that fires every second
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true // combining the scenePhase info with the info whether there are still cards to work thru
    
    var body: some View {
        //background behind cards
        ZStack{
            Image(decorative: "background") // adding decorative for accessibility
                .resizable()
                .ignoresSafeArea()
            // timer above cards
            VStack{
                Text("Time is \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                // cards above each other
                ZStack{
//                    ForEach(0..<cards.count, id:\.self) { index in
                    ForEach(cards) { card in
                        CardView(card: card){ isCorrect in
                            withAnimation {
                                removeCard(at: getIndex(of: card), isCorrect: isCorrect)
                            }
                        }
                            .stacked(at: getIndex(of: card), in: cards.count)
                            .allowsHitTesting(getIndex(of: card) == cards.count-1) // only allow the top most card to be dragged
                            .accessibilityHidden(getIndex(of: card) < cards.count-1) //hide card from voice over
                    }
                }
                .allowsHitTesting(timeRemaining > 0) //only allowing interactivy when there is still time remaining
                if cards.isEmpty {
                    Button("Start again", action:resetCards)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(.capsule)
                }
            }
            VStack{
                HStack{
                    Spacer() //pushing to the right
                    Button {
                        showingEditScreen.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
                    }
                }
                Spacer() //pushing to the top
            }
            .foregroundStyle(.white)
            .font(.largeTitle)
            .padding()
            // showing buttons for voice over as well
            if accessibilityDifferentiateWithoutColor || accessibilityVoiceOverEnabled {
                VStack{
                    Spacer()
                    HStack{
                        Button{
                            withAnimation {
                                removeCard(at: cards.count-1, isCorrect: false)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark you answer as wrong")
                        Spacer()
                        
                        Button{
                            withAnimation {
                                removeCard(at: cards.count-1, isCorrect: true)
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark you answer as correct")
                    }
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }.onReceive(timer) { time in
            guard isActive else {return} //making sure the timer pauses when the app goes into background
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                if cards.isEmpty == false { // make sure the timer does not restart when coming back from background when cards are empty
                    isActive = true
                }
            }
            else{
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) { EditCards()}
        .onAppear(perform: resetCards)
    }
    func removeCard(at index: Int, isCorrect: Bool){
        guard index >= 0 else { return } // only run this function if there are cards to remove
        print(isCorrect)
        if isCorrect{
            cards.remove(at: index)
        } else {
            let newCard = Card(id: UUID(), prompt: cards[index].prompt, answer: cards[index].answer)
            cards.remove(at: index)
            cards.insert(newCard, at: 0)
        }
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func getIndex(of card: Card) -> Int {
        for i in 0...cards.count {
            if cards[i].id == card.id {
                return i
            }
        }
        return -1
    }
    
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    func loadData(){
        if let data = UserDefaults.standard.data(forKey: "Cards"){
            if let decoded = try? JSONDecoder().decode([Card].self, from: data){
                cards = decoded
            }
        }
    }
}

#Preview {
    ContentView()
}


// solution for readding cards: https://www.hackingwithswift.com/forums/100-days-of-swiftui/day-91-flashzilla-challenge-2/7938/23763
