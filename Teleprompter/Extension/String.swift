// 
//  String.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 30.01.2026.
//
import Foundation

extension String {
  func index(offsetByWords wordCount: Int, from start: String.Index) -> String.Index {
    let utf16Start = self.utf16.distance(from: self.startIndex, to: start)
    
    let tokenizer = CFStringTokenizerCreate(
      kCFAllocatorDefault,
      self as CFString,
      CFRangeMake(0, self.utf16.count),
      kCFStringTokenizerUnitWord,
      CFLocaleCopyCurrent()
    )
    
    let status = CFStringTokenizerGoToTokenAtIndex(tokenizer, utf16Start)
    guard status != [] else {
      return start
    }
    
    var remaining = wordCount - 1
    var currentUTF16Index = utf16Start
    
    let firstRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
    currentUTF16Index = firstRange.location + firstRange.length
    
    
    while remaining > 0, CFStringTokenizerAdvanceToNextToken(tokenizer) != [] {
      let tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
      currentUTF16Index = tokenRange.location + tokenRange.length
      remaining -= 1
    }
    
    return self.utf16.index(self.startIndex, offsetBy: currentUTF16Index, limitedBy: self.utf16.endIndex) ?? self.endIndex
  }
  
  func countWords(from start: String.Index, to end: String.Index) -> Int {
    let utf16Start = self.utf16.distance(from: self.startIndex, to: start)
    let utf16End = self.utf16.distance(from: self.startIndex, to: end)
    
    let range = CFRange(location: utf16Start, length: utf16End - utf16Start)
    
    let tokenizer = CFStringTokenizerCreate(nil, self as CFString, range, kCFStringTokenizerUnitWord, nil)
    
    var words = 0
    while CFStringTokenizerAdvanceToNextToken(tokenizer) != [] {
      words += 1
    }
    
    return words
  }
  
  func nextAlphabetIndex(from index: String.Index) -> String.Index {
    var i = index
    
    while i < endIndex, !self[i].isLetter {
      i = self.index(after: i)
    }
    
    return i
  }
  
  func nsRange(from range: Range<String.Index>) -> NSRange {
    let location = utf16.distance(from: startIndex, to: range.lowerBound)
    let length = utf16.distance(from: range.lowerBound, to: range.upperBound)
    return NSRange(location: location, length: length)
  }
}
