//
//  Card.swift
//  Flashzilla
//
//  Created by Henrieke Baunack on 3/31/24.
//

import Foundation

struct Card: Codable, Identifiable {
    var id: UUID = UUID()
    var prompt: String
    var answer: String
    
    static let example = Card(prompt: "What is the capital of Germany?", answer: "Berlin")
}

