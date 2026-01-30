// 
//  GlobalRouter.swift
//  PlaygroundApp
//
//  Created by Bogdan Petkanych on 03.01.2026.
//

import SwiftUI
import Combine

class GlobalRouter {
  private var routingPath: Binding<NavigationPath>
  
  public init(path: Binding<NavigationPath>) {
    self.routingPath = path
  }
  
  func navigate<R: Routing>(to route: R) {
    routingPath.wrappedValue.append(route)
  }
  
  func back() {
    routingPath.wrappedValue.removeLast()
  }
}

private struct GlobalRouterKey: EnvironmentKey {
  static var defaultValue: GlobalRouter = .init(path: .constant(NavigationPath()))
}

extension EnvironmentValues {
  var globalRouter: GlobalRouter {
    get { self[GlobalRouterKey.self] }
    set { self[GlobalRouterKey.self] = newValue }
  }
}

