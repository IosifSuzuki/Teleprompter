// 
//  ScriptEditorRouter.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import SwiftUI

enum ScriptEditorRouter: Hashable, Routing {
  case scriptReader(text: String, locale: Locale)
  
  func view() -> some View {
    switch self {
      case let .scriptReader(text, locale):
        ScriptReaderView(
          viewModel: ScriptReaderViewModel(
            script: text,
            speechToTextService: SpeechToTextService(locale: locale)
          )
        )
    }
  }
}
