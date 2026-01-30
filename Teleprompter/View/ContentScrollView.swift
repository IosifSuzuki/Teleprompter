// 
//  ContentScrollView.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 30.01.2026.
//

import SwiftUI
import UIKit

struct ContentScrollView<Content: View>: UIViewRepresentable {
  let axes: Axis.Set
  @Binding var contentOffset: CGPoint
  @Binding var bounds: CGRect
  let content: Content
  
  init(
    axes: Axis.Set = .vertical,
    contentOffset: Binding<CGPoint>,
    bounds: Binding<CGRect>,
    @ViewBuilder content: () -> Content
  ) {
    self.axes = axes
    _contentOffset = contentOffset
    self.content = content()
    _bounds = bounds
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  func makeUIView(context: Context) -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = context.coordinator
    
    let host = UIHostingController(rootView: content)
    host.view.translatesAutoresizingMaskIntoConstraints = false
    
    context.coordinator.hostingController = host
    
    scrollView.addSubview(host.view)
    
    NSLayoutConstraint.activate([
      host.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      host.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      host.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
      host.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
    ])
    
    switch axes {
      case .horizontal:
        host.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
      case .vertical:
        host.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
      default:
        break
    }
    
    return scrollView
  }
  
  func updateUIView(_ scrollView: UIScrollView, context: Context) {
    context.coordinator.hostingController?.rootView = content
    
    if scrollView.contentOffset != contentOffset {
      scrollView.setContentOffset(contentOffset, animated: true)
    }
    
    if scrollView.bounds != bounds {
      bounds = scrollView.bounds
    }
  }
  
  class Coordinator: NSObject, UIScrollViewDelegate {
    var parent: ContentScrollView
    var hostingController: UIHostingController<Content>?
    
    init(_ parent: ContentScrollView) {
      self.parent = parent
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      parent.contentOffset = scrollView.contentOffset
      parent.bounds = scrollView.bounds
    }
  }
}
