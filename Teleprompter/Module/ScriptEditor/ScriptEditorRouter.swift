// 
//  ScriptEditorRouter.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import SwiftUI

enum ScriptEditorRouter: Hashable, Routing {
  case scriptReader(text: String)
  
  func view() -> some View {
    switch self {
      case let .scriptReader(text):
        ScriptReaderView(viewModel: ScriptReaderViewModel(script: text, speechToTextService: SpeechToTextService()))
    }
  }
}
