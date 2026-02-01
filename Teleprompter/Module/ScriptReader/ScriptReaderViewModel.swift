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
  @Published var formatedScript = AttributedString()
  @Published var currentContentOffset: CGPoint = .zero
  @Published var scrollBounds: CGRect = .zero
  @Published var scrollContentSize: CGSize = .zero
  private var preferences = Preferences()
  private var script: String
  
  private var windowWordsBackground: Color = .yellow
  private var currentWordBackground: Color = .red
  private var textColor: UIColor {
    UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
  }
  
  private var readTextColor: UIColor {
    UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark ? .darkGray : .lightGray
    }
  }
  
  private var currentWordRange: Range<String.Index>?
  private var readerWindow: ReaderWindow
  private var readerWindowSideOffset = 5
  private var readerWindowSubstring: Substring {
    script[readerWindow.startIndex..<readerWindow.endIndex]
  }
  private let speechToTextService: SpeechToTextService
  
  private var transcriptioSubscriber: AnyCancellable?
  private var cancellables = Set<AnyCancellable>()
  
  init(script: String, speechToTextService: SpeechToTextService) {
    self.script = script
    self.speechToTextService = speechToTextService
    self.readerWindow = ReaderWindow(
      startIndex: script.startIndex,
      currentStartWordIndex: script.startIndex,
      endIndex: script.index(offsetByWordsForward: readerWindowSideOffset, from: script.startIndex)
    )
    formatedScript = AttributedString(script, attributes: AttributeContainer(scriptAttributedString))
  }
  
  @MainActor
  func startRecording() {
    guard !isRecording else {
      return
    }
    
    isRecording = true
    
    transcriptioSubscriber = speechToTextService
      .transcriptionPublisher()
      .sink { _ in
        
      } receiveValue: { [weak self] model in
        guard let self, let word = model.lastWord else {
          return
        }
        
        print(word)
        
        var scriptWordRange: Range<String.Index>? = self.findWordNextExpectedWord(word: word)
        
        if scriptWordRange == nil {
          scriptWordRange = self.findWordInRepeatedRange(word: word)
        }
        if scriptWordRange == nil {
          scriptWordRange = self.findWordInForwardReaderWindow(word: word)
        }
        if scriptWordRange == nil {
          scriptWordRange = self.findWordInBackwardReaderWindow(word: word)
        }

        if let scriptWordRange {
          self.currentWordRange = scriptWordRange
          let readWordsInsideReaderWindow = self.script.countWords(
            from: self.readerWindow.startIndex,
            to: scriptWordRange.lowerBound
          )
          var newReaderWindow = self.readerWindow
          newReaderWindow.currentStartWordIndex = scriptWordRange.lowerBound
          if readWordsInsideReaderWindow > readerWindowSideOffset {
            let readerWindowStartIndex = self.script.index(
              offsetByWordsForward: readWordsInsideReaderWindow - readerWindowSideOffset,
              from: self.readerWindow.startIndex
            )
            newReaderWindow.startIndex = self.script.nextAlphabetIndex(from: readerWindowStartIndex)
          }
          newReaderWindow.endIndex = self.script.index(
            offsetByWordsForward: readerWindowSideOffset + 1,
            from: scriptWordRange.lowerBound
          )
          self.readerWindow = newReaderWindow
        }
        
        self.highlightReadScript()
        
        if self.preferences.isDebugMode {
          self.highlightReadWindowScript()
        }
        
        if self.currentWordRange != nil {
          keepCurrentWordInScrollBounds()
        }
      }
  }
  
  @MainActor
  func stopRecording() {
    guard isRecording else {
      return
    }
    isRecording = false
    transcriptioSubscriber?.cancel()
  }
}

// MARK: - UI Begavuour

private extension ScriptReaderViewModel {
  func highlightReadWindowScript() {
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
  
  func highlightReadScript() {
    guard
      let currentWordRange,
      let currentWordEndIndex = AttributedString.Index(currentWordRange.upperBound, within: self.formatedScript)
    else {
      return
    }
    self.formatedScript[...currentWordEndIndex].foregroundColor = readTextColor
  }
  
  func keepCurrentWordInScrollBounds() {
    let nsRange = self.script.nsRange(from: self.readerWindow.startIndex..<self.readerWindow.endIndex)
    
    let nsAttributedString = NSAttributedString(
      string: script,
      attributes: scriptAttributedString,
    )
    guard
      let selectedWordWindowFrame = nsAttributedString.rectForSelectedRange(nsRange, width: scrollBounds.width),
      scrollBounds.contains(selectedWordWindowFrame)
    else {
      return
    }
    
    let offsetY = max(0, selectedWordWindowFrame.minY)
    currentContentOffset.y = min(self.scrollContentSize.height - self.scrollBounds.height, offsetY)
  }
}

// MARK: - Find word in script
private extension ScriptReaderViewModel {
  func findWordNextExpectedWord(word: String) -> Range<String.Index>? {
    let findWordPattern = word.wordPatternRegex
    let nextExpectedWordStartIndex = self.script.nextAlphabetIndex(
      from: self.script.index(offsetByWordsForward: 1, from: self.readerWindow.currentStartWordIndex)
    )
    let nextExpectedWordEndIndex = self.script.nextAlphabetIndex(
      from: self.script.index(offsetByWordsForward: 2, from: self.readerWindow.currentStartWordIndex)
    )
    
    return script.range(
      of: findWordPattern,
      options: [.caseInsensitive, .regularExpression],
      range: nextExpectedWordStartIndex..<nextExpectedWordEndIndex
    )
  }
  
  func findWordInForwardReaderWindow(word: String) -> Range<String.Index>? {
    let findWordPattern = word.wordPatternRegex
    let nextExpectedWordIndex = script.nextAlphabetIndex(
      from: script.index(offsetByWordsForward: 1, from: readerWindow.currentStartWordIndex)
    )
    
    return script.range(
      of: findWordPattern,
      options: [.caseInsensitive, .regularExpression],
      range: nextExpectedWordIndex..<max(nextExpectedWordIndex, readerWindow.endIndex)
    )
  }
  
  func findWordInRepeatedRange(word: String) -> Range<String.Index>? {
    let findWordPattern = word.wordPatternRegex
    let nextExpectedWordStartIndex = script.nextAlphabetIndex(
      from: script.index(offsetByWordsForward: 1, from: readerWindow.currentStartWordIndex)
    )
    
    return script.range(
      of: findWordPattern,
      options: [.caseInsensitive, .regularExpression],
      range: readerWindow.currentStartWordIndex..<nextExpectedWordStartIndex
    )
  }
  
  func findWordInBackwardReaderWindow(word: String) -> Range<String.Index>? {
    let findWordPattern = word.wordPatternRegex
    
    return script.range(
      of: findWordPattern,
      options: [.caseInsensitive, .regularExpression],
      range: readerWindow.startIndex..<readerWindow.currentStartWordIndex
    )
  }
}

private extension ScriptReaderViewModel {
  var scriptAttributedString: [NSAttributedString.Key : Any] {
    let baseFont = UIFont.systemFont(ofSize: 40)
    let scaledFont = UIFontMetrics.default.scaledFont(for: baseFont)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byWordWrapping
    
    paragraphStyle.minimumLineHeight = scaledFont.lineHeight
    paragraphStyle.maximumLineHeight = scaledFont.lineHeight
    paragraphStyle.lineSpacing = 0
    return [
      .font: scaledFont,
      .foregroundColor: textColor,
      .paragraphStyle: paragraphStyle
    ]
  }
}
