// 
//  SpeachToTextServiceProtocol.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import Foundation

protocol SpeechToTextServiceProtocol {
  func authorize() async throws
  func transcribe() -> AsyncThrowingStream<TranscriptionModel, Error>
  func stopTranscribing()
}
