// 
//  Error.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 02.02.2026.
//

import Foundation

struct LocalizedAlertError: LocalizedError {
  let underlyingError: LocalizedError
  var errorDescription: String? {
    underlyingError.errorDescription
  }
  var recoverySuggestion: String? {
    underlyingError.recoverySuggestion
  }
  
  init?(error: Error?) {
    guard let localizedError = error as? LocalizedError else { return nil }
    underlyingError = localizedError
  }
}

enum SpeechPermissionError: LocalizedError {
  case microphoneDenied
  case recognizerUnavailable
  
  var errorDescription: String? {
    switch self {
      case .microphoneDenied:
        return "Microphone access was denied. Please enable it in Settings."
      case .recognizerUnavailable:
        return "Speech recognition service is currently unavailable."
    }
  }
}
