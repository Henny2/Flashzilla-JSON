//
//  CardView.swift
//  Flashzilla
//
//  Created by Henrieke Baunack on 3/31/24.
//

import SwiftUI
// in General tab of Project we disallowed portrait mode
struct CardView: View {
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor  // for red green blindness
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    
    @State private var isDragged = false
    
    let card: Card
    var removal: ((Bool) -> Void)? = nil
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero // no drag by default
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .fill(
                    accessibilityDifferentiateWithoutColor
                    ? .white
                    :.white
                    .opacity(1 - Double(abs(offset.width/50.0))))
                .background(
                    accessibilityDifferentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25)
                        .fill(isDragged ? (offset.width>0 ? .green : .red) : .white )) // is postive when dragged to the right, negative when dragged to the left
                .shadow(radius: 10)
            VStack{
                // for voice over we only show either the prompt or the answer, this swap will trigger voice over to read out the answer when it appears
                if accessibilityVoiceOverEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                }
                else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        // this frame size fits on all the iphone screens out there
        .frame(width:450, height:250)
        .rotationEffect(.degrees(offset.width/5.0))
        .offset(x:offset.width*5)
        .opacity(2-Double(abs(offset.width/50)))
        .accessibilityAddTraits(.isButton) // for voiceover, making clear that the card can be tapped
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    isDragged = true
                }
                .onEnded { _ in
                    isDragged = false
                    if abs(offset.width) > 100 {
                        removal?(offset.width > 0)
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
        .animation(.default, value: offset) // animating the springing back to the middle
    }
}

#Preview {
    CardView(card: Card.example)
}

