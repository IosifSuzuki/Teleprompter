// 
//  SpeechToTextService.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import AVFoundation
import Foundation
import Speech
import Combine

class SpeechToTextService: NSObject {
  private var audioEngine: AVAudioEngine?
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var task: SFSpeechRecognitionTask?
  private let recognizer: SFSpeechRecognizer?
  
  private let speachAuthorizationStatusSubject = PassthroughSubject<SpeachAuthorizationStatus, Error>()
  private let transcriptionSubject = PassthroughSubject<Transcription, Error>()
  
  init(locale: Locale = .current) {
    self.recognizer = SFSpeechRecognizer(locale: locale)
  }
}

private extension SpeechToTextService {
  func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
    let audioEngine = AVAudioEngine()
    let request = SFSpeechAudioBufferRecognitionRequest()
    request.addsPunctuation = false
    request.shouldReportPartialResults = true
    
    request.taskHint = .dictation
    
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(.record, mode: .measurement)
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
  
  func cleanUp() {
    audioEngine?.stop()
    audioEngine?.inputNode.removeTap(onBus: 0)
  }
}

extension SpeechToTextService: SFSpeechRecognitionTaskDelegate {
  
  func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
    let segments = transcription.segments.map { segment in
      Transcription.Segment(
        phrase: segment.substring,
        confidence: segment.confidence
      )
    }
    
    let model = Transcription(segments: segments)
    transcriptionSubject.send(model)
  }
}

extension SpeechToTextService: SpeechToTextServiceProtocol {
  
  func speachAuthorizationStatusPublisher() -> AnyPublisher<SpeachAuthorizationStatus, Never> {
    Future { [weak self] promise in
      guard let self else {
        return
      }
      
      Task {
        guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
          promise(.success(.recognizerUnavailable))
          return
        }
        
        guard let recognizer = self.recognizer else {
          promise(.success(.recognizerUnavailable))
          return
        }
        
        guard recognizer.isAvailable else {
          promise(.success(.recognizerUnavailable))
          return
        }
        
        guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
          promise(.success(.microphoneDenied))
          return
        }
        
        promise(.success(.authorized))
      }
    }
    .eraseToAnyPublisher()
  }
  
  func transcriptionPublisher() -> AnyPublisher<Transcription, Error> {
    do {
      let (audioEngine, request) = try self.prepareEngine()
      self.audioEngine = audioEngine
      self.request = request
      task = recognizer?.recognitionTask(with: request, delegate: self)
    } catch {
      return Fail(error: error)
        .eraseToAnyPublisher()
    }
    
    return
      transcriptionSubject
      .handleEvents(receiveCancel: { [weak self] in
        self?.cleanUp()
      })
      .eraseToAnyPublisher()
  }
}
