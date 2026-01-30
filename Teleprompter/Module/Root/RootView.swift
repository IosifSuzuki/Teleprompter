// 
//  RootView.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import SwiftUI

struct RootView: View {
  @State private var rootPath = NavigationPath()
  
  var body: some View {
    NavigationStack(path: $rootPath) {
      ScriptEditorView()
    }
    .environment(\.globalRouter, GlobalRouter(path: $rootPath))
  }
}
