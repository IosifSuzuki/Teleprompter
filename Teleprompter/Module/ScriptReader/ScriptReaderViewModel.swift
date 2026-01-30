// 
//  ScriptReaderViewModel.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import Combine
import Foundation
import SwiftUI

class ScriptReaderViewModel: ObservableObject {
  @Published var isRecording = false
  @Published var formatedScript: AttributedString
  @Published var transcription: TranscriptionModel?
  @Published var currentContentOffset: CGPoint = .zero
  @Published var scrollBounds: CGRect = .zero
  private var preferences = Preferences()
  private var script: String
  
  private var windowWordsBackground: Color = .yellow
  private var currentWordBackground: Color = .red
  
  private var currentWordRange: Range<String.Index>?
  private var readerWindow: ReaderWindow
  private var readerWindowSideOffset = 5
  private var readerWindowSubstring: Substring {
    script[readerWindow.startIndex..<readerWindow.endIndex]
  }
  private let speechToTextService: SpeechToTextService
  private var transcriptionTask: Task<Void, Never>?
  
  private var cancellables = Set<AnyCancellable>()
  
  init(script: String, speechToTextService: SpeechToTextService) {
    self.script = script
    self.speechToTextService = speechToTextService
    self.readerWindow = ReaderWindow(
      startIndex: script.startIndex,
      currentStartWordIndex: script.startIndex,
      endIndex: script.index(offsetByWords: readerWindowSideOffset, from: script.startIndex)
    )
    formatedScript = AttributedString(script)
    formatedScript.font = .system(size: 20)
    
    configureSubscriptions()
  }
  
  func configureSubscriptions() {
    $transcription
      .map { model -> String? in
        guard
          let currentText = model?.currentText, !currentText.isEmpty,
          let wordSubstring = currentText.split(separator: " ").last?.trimmingCharacters(in: .punctuationCharacters)
        else {
          return nil
        }
        return String(wordSubstring)
      }
      .sink { [weak self] word in
        guard let self, let word else {
          return
        }
        
        let findWordPattern = "\\b\(word)\\b"
        if self.readerWindowSubstring.range(
          of: findWordPattern,
          options: [.caseInsensitive, .regularExpression]
        ) != nil {
          let nextExpectedWordIndex = self.script.nextAlphabetIndex(
            from: self.script.index(offsetByWords: 1, from: self.readerWindow.currentStartWordIndex)
          )
          var scriptWordRange: Range<String.Index>
          if let nextScriptWordRange = self.script.range(
            of: findWordPattern,
            options: [.caseInsensitive, .regularExpression],
            range: nextExpectedWordIndex..<self.readerWindow.endIndex
          ) {
            scriptWordRange = nextScriptWordRange
          } else if let currentWordRange = self.script.range(
            of: findWordPattern,
            options: [.caseInsensitive, .regularExpression],
            range: self.readerWindow.currentStartWordIndex..<nextExpectedWordIndex
          ) {
            scriptWordRange = currentWordRange
          } else if let previousScriptWordRange = self.script.range(
            of: findWordPattern,
            options: [.caseInsensitive, .regularExpression],
            range: self.readerWindow.startIndex..<self.readerWindow.currentStartWordIndex
          ) {
            scriptWordRange = previousScriptWordRange
          } else {
            scriptWordRange = self.currentWordRange ?? self.readerWindow.startIndex..<self.readerWindow.endIndex
          }
          self.currentWordRange = scriptWordRange
          let readedWordsInsideReaderWindow = self.script.countWords(
            from: self.readerWindow.startIndex,
            to: scriptWordRange.lowerBound
          )
          var newReaderWindow = self.readerWindow
          newReaderWindow.currentStartWordIndex = scriptWordRange.lowerBound
          if readedWordsInsideReaderWindow > readerWindowSideOffset {
            let readerWindowStartIndex = self.script.index(
              offsetByWords: readedWordsInsideReaderWindow - readerWindowSideOffset,
              from: self.readerWindow.startIndex
            )
            newReaderWindow.startIndex = self.script.nextAlphabetIndex(from: readerWindowStartIndex)
          }
          newReaderWindow.endIndex = self.script.index(
            offsetByWords: readerWindowSideOffset + 1,
            from: scriptWordRange.lowerBound
          )
          self.readerWindow = newReaderWindow
        }
        
        if self.preferences.isDebugMode {
          self.highlightScript()
        }
        
        keepCurrentWordInScrollBounds()
      }
      .store(in: &cancellables)
  }
  
  @MainActor
  func startRecording() {
    guard !isRecording else {
      return
    }
    
    isRecording = true
    
    transcriptionTask = Task {
      do {
        try await speechToTextService.authorize()
        
        let stream = speechToTextService.transcribe()
        for try await partialResult in stream {
          self.transcription = partialResult
        }
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  @MainActor
  func stopRecording() {
    guard isRecording else {
      return
    }
    isRecording = false
    transcriptionTask?.cancel()
    transcriptionTask = nil
    speechToTextService.stopTranscribing()
  }
  
  func highlightScript() {
    self.formatedScript.backgroundColor = .clear
    
    let formatedReaderWindowStartIndex = AttributedString.Index(self.readerWindow.startIndex, within: self.formatedScript)
    let formatedReaderWindowEndIndex = AttributedString.Index(self.readerWindow.endIndex, within: self.formatedScript)
    if let formatedReaderWindowStartIndex, let formatedReaderWindowEndIndex {
      self.formatedScript[formatedReaderWindowStartIndex..<formatedReaderWindowEndIndex].backgroundColor = windowWordsBackground
    }
    
    if let currentWordRange {
      let currentWordStartIndex = AttributedString.Index(currentWordRange.lowerBound, within: self.formatedScript)
      let currentWordEndIndex = AttributedString.Index(currentWordRange.upperBound, within: self.formatedScript)
      if let currentWordStartIndex, let currentWordEndIndex {
        self.formatedScript[currentWordStartIndex..<currentWordEndIndex].backgroundColor = currentWordBackground
      }
    }
  }
  
  func keepCurrentWordInScrollBounds() {
    guard let currentWordRange else {
      return
    }
    let nsRange = self.script.nsRange(from: currentWordRange)
    
    
    let nsAttributedString = NSAttributedString(
      string: script,
      attributes: [
        .font: UIFont.systemFont(ofSize: 20),
      ]
    )
    guard let selectedWordFrame = nsAttributedString.rectForSelectedRange(nsRange, visibleRect: scrollBounds) else {
      return
    }
    
    let offsetY = max(0, selectedWordFrame.minY)
    currentContentOffset.y = min(scrollBounds.maxY, scrollBounds.minY + offsetY)
  }
}
