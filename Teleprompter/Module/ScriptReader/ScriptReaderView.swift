// 
//  ScriptReaderView.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import SwiftUI
import UIKit

struct ScriptReaderView: View {
  @ObservedObject var viewModel: ScriptReaderViewModel
  var body: some View {
    ContentScrollView(
      contentOffset: $viewModel.currentContentOffset,
      bounds: $viewModel.scrollBounds,
      contentSize: $viewModel.scrollContentSize,
      contentInset: viewModel.contentInset
    ) {
      Text(viewModel.formatedScript)
        .foregroundStyle(.white)
        .lineLimit(nil)
        .frame(maxWidth: .infinity)
    }
    .errorAlert(error: $viewModel.error)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Script Reader")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          toggleRecord()
        }) {
          Image(systemName: viewModel.isRecording ? "mic.fill" : "mic")
            .foregroundColor(viewModel.isRecording ? .red : .blue)
        }
      }
    }
  }
  
  private func toggleRecord() {
    if viewModel.isRecording {
      viewModel.stopRecording()
    } else {
      viewModel.startRecording()
    }
  }
}
