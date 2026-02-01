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
      contentInset: UIEdgeInsets(top: 8, left: 8, bottom: -8, right: -8)
    ) {
      Text(viewModel.formatedScript)
        .foregroundStyle(.white)
        .lineLimit(nil)
        .frame(maxWidth: .infinity)
    }
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
