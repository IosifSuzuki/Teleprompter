// 
//  ScriptEditorViewModel.swift
//  Teleprompter
//
//  Created by Bogdan Petkanych on 25.01.2026.
//

import Combine
import SwiftUI

class ScriptEditorViewModel: ObservableObject {
  @Published var text: String = ""
  @Published var preferences = Preferences()
  @Published var selectedLanguage: Language = .english

  let preparedEnScript = """
  Well you only need the light when it's burning low
  Only miss the sun when it starts to snow
  Only know you love her when you let her go
  Only know you've been high when you're feeling low
  Only hate the road when you're missing home
  Only know you love her when you let her go
  And you let her go
  Staring at the bottom of your glass
  Hoping one day you'll make a dream last
  But dreams come slow and they go so fast
  You see her when you close your eyes
  Maybe one day you'll understand why
  Everything you touch surely dies
  But you only need the light when it's burning low
  Only miss the sun when it starts to snow
  Only know you love her when you let her go
  Only know you've been high when you're feeling low
  Only hate the road when you're missing home
  Only know you love her when you let her go
  Staring at the ceiling in the dark
  Same old empty feeling in your heart
  'Cause love comes slow and it goes so fast
  Well you see her when you fall asleep
  But never to touch and never to keep
  'Cause you loved her too much and you dive too deep
  Well you only need the light when it's burning low
  Only miss the sun when it starts to snow
  Only know you love her when you let her go
  Only know you've been high when you're feeling low
  Only hate the road when you're missing home
  Only know you love her when you let her go
  And you let her go
  Oh oh oh no
  And you let her go
  Oh oh oh no
  Well you let her go
  'Cause you only need the light when it's burning low
  Only miss the sun when it starts to snow
  Only know you love her when you let her go
  Only know you've been high when you're feeling low
  Only hate the road when you're missing home
  Only know you love her when you let her go
  'Cause you only need the light when it's burning low
  Only miss the sun when it starts to snow
  Only know you love her when you let her go
  Only know you've been high when you're feeling low
  Only hate the road when you're missing home
  Only know you love her when you let her go
  """
  
  private var preparedHiScript = """
  यह एक डमी हिंदी पाठ है जिसका उपयोग केवल अभ्यास और उदाहरण के लिए किया जा रहा है। इस पाठ का उद्देश्य यह दिखाना है कि जब कोई लंबा हिंदी अनुच्छेद लिखा जाता है तो वह पढ़ने में कैसा लगता है। हिंदी हमारी मातृभाषा है और इसे पढ़ना व लिखना बहुत आनंददायक होता है।
  
  भारत एक विविधताओं से भरा देश है जहाँ अनेक भाषाएँ, संस्कृतियाँ और परंपराएँ पाई जाती हैं। यहाँ के लोग अलग-अलग त्योहार मनाते हैं और मिल-जुलकर रहते हैं। गाँव हो या शहर, हर जगह जीवन की अपनी अलग पहचान होती है।
  
  आज के समय में शिक्षा का महत्व बहुत बढ़ गया है। बच्चों को अच्छी शिक्षा देना हर माता-पिता का सपना होता है। विद्यालय न केवल पढ़ाई का स्थान होता है, बल्कि वहाँ बच्चों को अनुशासन, सहयोग और नैतिक मूल्यों की भी सीख मिलती है।
  
  तकनीक ने हमारे जीवन को बहुत आसान बना दिया है। मोबाइल फोन, कंप्यूटर और इंटरनेट की मदद से हम दुनिया से जुड़े रहते हैं। अब बच्चे भी ऑनलाइन पढ़ाई कर सकते हैं और नई-नई चीजें सीख सकते हैं।
  
  स्वास्थ्य भी जीवन का एक महत्वपूर्ण भाग है। अच्छा खान-पान, नियमित व्यायाम और समय पर आराम करना बहुत जरूरी है। यदि हम अपने शरीर और मन का ध्यान रखें, तो जीवन सुखी और सफल बन सकता है।
  
  अंत में, यह कहा जा सकता है कि संतुलित जीवन जीना ही सबसे बड़ा सुख है। मेहनत, ईमानदारी और सकारात्मक सोच से हम अपने लक्ष्य आसानी से प्राप्त कर सकते हैं।
  """
  
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    configureSubscriptions()
  }
  
  func configureSubscriptions() {
    preferences.$isDebugMode
      .sink { [weak self] isDebugMode in
        guard let self, isDebugMode else {
          return
        }
        self.preselectScipt(language: self.selectedLanguage)
      }
      .store(in: &cancellables)
    
    $selectedLanguage.sink { [weak self] language in
      guard let self, self.preferences.isDebugMode else {
        return
      }
      self.preselectScipt(language: language)
    }
    .store(in: &cancellables)
  }
}

private extension ScriptEditorViewModel {
  func preselectScipt(language: Language) {
    self.text = switch language {
      case .english:
        self.preparedEnScript
      case .hindi:
        self.preparedHiScript
    }
  }
}
