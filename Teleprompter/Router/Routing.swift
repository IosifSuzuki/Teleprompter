// 
//  Routing.swift
//  PlaygroundApp
//
//  Created by Bogdan Petkanych on 03.01.2026.
//
import SwiftUI

protocol Routing: Hashable {
  associatedtype Destination: View
  
  func view() -> Self.Destination
}
