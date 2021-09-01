//
//  State+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import SwiftUI

func convertToId<T>(_ state: State<T?>) -> Binding<String?> where T: Identifiable, T.ID == String {
    Binding<String?>(get: { state.wrappedValue?.id }, set: { state.wrappedValue = $0 != nil ? state.wrappedValue : nil })
}
