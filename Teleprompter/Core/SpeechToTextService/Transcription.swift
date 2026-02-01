//
//  Transcription.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import Foundation

struct Transcription {
  var segments: [Segment]
  
  struct Segment {
    let phrase: String
    let confidence: Float
  }
  
  var veryHighConfidence: [Segment] {
    segments.filter {
      $0.confidence >= 0.9
    }
    .sorted { $0.confidence > $1.confidence }
  }
  
  var mediumConfidence: [Segment] {
    segments.filter {
      $0.confidence >= 0.7 && $0.confidence < 0.9
    }
    .sorted { $0.confidence > $1.confidence }
  }
  
  var lowConfidence: [Segment] {
    segments.filter {
      $0.confidence < 0.7
    }
    .sorted { $0.confidence > $1.confidence }
  }
  
  var words: [String] {
    segments.flatMap {
      $0.phrase
        .components(separatedBy: .whitespacesAndNewlines)
        .map { $0.trimmingCharacters(in: .punctuationCharacters) }
        .filter { !$0.isEmpty }
    }
  }
  
  var lastWord: String? {
    words.last
  }
  
  var description: String {
    return segments.map {
      String(format: "word: %@, confidence: %.2f", $0.phrase, $0.confidence)
    }.joined(separator: "\n")
  }
}
