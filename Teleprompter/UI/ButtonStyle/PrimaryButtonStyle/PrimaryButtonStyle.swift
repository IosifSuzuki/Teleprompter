// 
//  PrimaryButtonStyle.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) var isEnabled
  
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration
      .label
      .font(.callout)
      .fontWeight(.semibold)
      .foregroundStyle(isEnabled ? .white : .white.opacity(0.9))
      .frame(maxWidth: .infinity)
      .padding(.vertical, 14)
      .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(configuration.isPressed ? .blue : .blue.opacity(0.9))
      )
      .animation(.smooth, value: configuration.isPressed)
  }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
  static var primary: PrimaryButtonStyle {
    .init()
  }
}
