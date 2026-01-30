// 
//  ScriptEditorView.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import SwiftUI

struct ScriptEditorView: View {
  @Environment(\.globalRouter) var globalRouter
  @StateObject private var viewModel = ScriptEditorViewModel()
  
  var body: some View {
    ScrollView {
      VStack(spacing: 12) {
        textEditor
        completeButton
        Spacer()
      }
    }
    .navigationDestination(type: ScriptEditorRouter.self)
    .padding()
    .toolbar(content: navigationBar)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Script Editor")
  }
  
  @ToolbarContentBuilder
  func navigationBar() -> some ToolbarContent {
    ToolbarItemGroup(placement: .topBarTrailing) {
      debugToggle
    }
  }
}

// MARK: - SubViews
extension ScriptEditorView {
  var textEditor: some View {
    TextField(
      "Type your script here",
      text: $viewModel.text,
      axis: .vertical
    )
    .font(.body)
    .lineLimit(5...)
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 8).strokeBorder(.blue)
    )
    .multilineTextAlignment(.leading)
  }
  
  var completeButton: some View {
    Button {
      globalRouter.navigate(
        to: ScriptEditorRouter.scriptReader(text: viewModel.text)
      )
    } label: {
      Text("Done")
    }
    .disabled(viewModel.text.isEmpty)
    .buttonStyle(.primary)
  }
  
  var debugToggle: some View {
    Toggle("Debug", isOn: $viewModel.preferences.isDebugMode)
  }
}

#Preview {
  ScriptEditorView()
}
