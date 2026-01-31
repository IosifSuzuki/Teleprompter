// 
//  Language.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 31.01.2026.
//

import Foundation

enum Language: String, CaseIterable, Identifiable {
  case english = "en"
  case hindi = "hi"
  
  var id: String { rawValue }
  
  var locale: Locale {
    Locale(identifier: self.rawValue)
  }
  
  var title: String {
    switch self {
      case .english:
        return "English"
      case .hindi:
        return "हिन्दी"
    }
  }
}
