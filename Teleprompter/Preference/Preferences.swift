// 
//  Preferences.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 30.01.2026.
//

struct Preferences {
  private enum Key {
    static let isDebugMode = "isDebugMode"
  }
  
  @UserDefault(Preferences.Key.isDebugMode) var isDebugMode = true
}
