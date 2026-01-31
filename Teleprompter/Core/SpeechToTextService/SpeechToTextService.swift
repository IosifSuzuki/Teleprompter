// 
//  SpeechToTextService.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import AVFoundation
import Foundation
import Speech

class SpeechToTextService: SpeechToTextServiceProtocol {
  private var accumulatedText: String = ""
  
  private var audioEngine: AVAudioEngine?
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var task: SFSpeechRecognitionTask?
  private let recognizer: SFSpeechRecognizer?
  
  init(locale: Locale = .current) {
    self.recognizer = SFSpeechRecognizer(locale: locale)
  }
  
  /// Requests permissions and verifies the availability of the speech recognizer.
  /// - Throws: `RecognizerError` if the recognizer is unavailable or if the necessary permissions are not granted.
  func authorize() async throws {
    guard let recognizer = self.recognizer else {
      throw RecognizerError.recognizerUnavailable
    }
    
    let hasAuthorization = await SFSpeechRecognizer.hasAuthorizationToRecognize()
    guard hasAuthorization else {
      throw RecognizerError.notAuthorizedToRecognize
    }
    
    let hasRecordPermission = await AVAudioSession.sharedInstance().hasPermissionToRecord()
    guard hasRecordPermission else {
      throw RecognizerError.notPermittedToRecord
    }
    
    if !recognizer.isAvailable {
      throw RecognizerError.recognizerUnavailable
    }
  }
  
  deinit {
    reset()
  }
  
  /// Starts the speech-to-text transcription process.
  /// - Returns: An `AsyncThrowingStream` that emits strings of transcribed text.
  @MainActor
  func transcribe() -> AsyncThrowingStream<TranscriptionModel, Error> {
    AsyncThrowingStream { continuation in
      Task {
        do {
          let (audioEngine, request) = try Self.prepareEngine()
          self.audioEngine = audioEngine
          self.request = request
          
          guard let recognizer = self.recognizer else {
            throw RecognizerError.recognizerUnavailable
          }
          
          self.task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else {
              return
            }
            
            if let error = error {
              continuation.finish(throwing: error)
              self.reset()
              return
            }
            
            if let result = result {
              let newText = result.bestTranscription.formattedString
              
              let model = TranscriptionModel(
                finalizedText: self.accumulatedText,
                currentText: newText, isRecording: false
              )
              
              continuation.yield(model)
              
              if result.speechRecognitionMetadata != nil {
                self.accumulatedText += newText + " "
              }
              
              if result.isFinal {
                continuation.finish()
                self.reset()
              }
            }
          }
        } catch {
          continuation.finish(throwing: error)
          self.reset()
        }
      }
    }
  }
  
  /// Stops the transcription process and releases associated resources.
  func stopTranscribing() {
    reset()
  }
  
  /// Resets and releases the resources used by the speech recognition service.
  func reset() {
    task?.cancel()
    task = nil
    audioEngine?.stop()
    audioEngine = nil
    request = nil
    accumulatedText = ""
  }
  
  /// Prepares the audio engine and speech recognition request.
  /// - Returns: A tuple containing the configured `AVAudioEngine` and `SFSpeechAudioBufferRecognitionRequest`.
  private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
    let audioEngine = AVAudioEngine()
    let request = SFSpeechAudioBufferRecognitionRequest()
    request.addsPunctuation = true
    request.taskHint = .dictation
    request.shouldReportPartialResults = true
    
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    
    let inputNode = audioEngine.inputNode
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
      request.append(buffer)
    }
    
    audioEngine.prepare()
    try audioEngine.start()
    
    return (audioEngine, request)
  }
}
