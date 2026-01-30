// 
//  RecognizerError.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import Foundation

enum RecognizerError: Error {
  case nilRecognizer
  case notAuthorizedToRecognize
  case notPermittedToRecord
  case recognizerUnavailable
  case invalidAudioSession
  
  var message: String {
    switch self {
      case .nilRecognizer:
        return "Can't initialize speech recognizer"
      case .notAuthorizedToRecognize:
        return "Not authorized to recognize speech"
      case .notPermittedToRecord:
        return "Not permitted to record audio"
      case .recognizerUnavailable:
        return "Recognizer is unavailable"
      case .invalidAudioSession:
        return "The audio session is invalid"
    }
  }
}
