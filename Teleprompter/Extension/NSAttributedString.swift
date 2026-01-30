// 
//  NSAttributedString.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 30.01.2026.
//

import UIKit
import SwiftUI

extension NSAttributedString {
  func visibleText(in visibleRect: CGRect) -> NSAttributedString? {
    let textStorage = NSTextStorage(attributedString: self)
    let textContainer = NSTextContainer(size: CGSize(width: visibleRect.width, height: .greatestFiniteMagnitude))
    textContainer.lineFragmentPadding = 0
    textContainer.maximumNumberOfLines = 0
    
    let layoutManager = NSLayoutManager()
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    
    layoutManager.ensureLayout(for: textContainer)
    
    let startGlyph = layoutManager.glyphIndex(for: visibleRect.origin, in: textContainer)
    let endPoint = CGPoint(x: visibleRect.maxX, y: visibleRect.maxY)
    let endGlyph = layoutManager.glyphIndex(for: endPoint, in: textContainer)
    
    let startChar = layoutManager.characterIndexForGlyph(at: startGlyph)
    let endChar = layoutManager.characterIndexForGlyph(at: endGlyph)
    
    guard startChar < endChar else {
      return nil
    }
    return self.attributedSubstring(from: NSRange(location: startChar, length: endChar - startChar))
  }
  
  func rectForSelectedRange(_ range: NSRange, visibleRect: CGRect) -> CGRect? {
    guard range.location + range.length <= self.length else {
      return nil
    }
    
    let textStorage = NSTextStorage(attributedString: self)
    let textContainer = NSTextContainer(size: CGSize(width: visibleRect.width, height: .greatestFiniteMagnitude))
    textContainer.lineFragmentPadding = 0
    textContainer.maximumNumberOfLines = 0
    
    let layoutManager = NSLayoutManager()
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    
    layoutManager.ensureLayout(for: textContainer)
    
    let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
    var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    
    if rect.maxY < visibleRect.minY || rect.minY > visibleRect.maxY {
      return nil
    }
    
    rect.origin.y -= visibleRect.origin.y
    return rect
  }
}
