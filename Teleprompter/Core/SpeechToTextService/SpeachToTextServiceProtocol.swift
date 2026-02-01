// 
//  SpeachToTextServiceProtocol.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import Foundation
import Combine

protocol SpeechToTextServiceProtocol {
  func speachAuthorizationStatusPublisher() -> AnyPublisher<SpeachAuthorizationStatus, Never>
  func transcriptionPublisher() -> AnyPublisher<Transcription, Error>
}
