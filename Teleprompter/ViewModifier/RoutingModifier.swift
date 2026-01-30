// 
//  RoutingModifier.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import SwiftUI

struct RoutingModifier<R: Routing>: ViewModifier {
  
  func body(content: Content) -> some View {
    content
      .navigationDestination(
        for: R.self,
        destination: { routing in
          routing.view()
        }
      )
  }
}

extension View {
  func navigationDestination<R: Routing>(type: R.Type) -> some View {
    modifier(RoutingModifier<R>())
  }
}
