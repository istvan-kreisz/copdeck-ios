//
//  Binding+Extensions.swift
//  CopDeck
//
//  Created by István Kreisz on 10/19/21.
//

import Foundation
import SwiftUI

extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, replacingNilWith nilProxy: Value) {
        self.init(get: { source.wrappedValue ?? nilProxy },
                  set: { newValue in
                      if newValue == nilProxy {
                          source.wrappedValue = nil
                      } else {
                          source.wrappedValue = newValue
                      }
                  })
    }
}
