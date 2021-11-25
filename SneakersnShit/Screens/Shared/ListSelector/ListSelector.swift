//
//  ListSelector.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/19/21.
//

import SwiftUI

struct ListSelector: View {
    @Environment(\.presentationMode) var presentationMode

    let title: String
    var description: String?
    let buttonTitle: String
    let enableMultipleSelection: Bool
    let popBackOnSelect: Bool
    let options: [String]
    var isContentLocked: Bool = false
    @Binding var selectedOptions: [String]
    let buttonTapped: () -> Void

    @State var showPaymentView = false

    var body: some View {
        Group {
            if isContentLocked && DebugSettings.shared.isPaywallEnabled {
                NavigationLink(destination: PaymentView(viewType: .subscribe, animateTransition: false) { showPaymentView = false }
                    .environmentObject(DerivedGlobalStore.default),
                    isActive: $showPaymentView) { EmptyView() }
            }

            SettingMenu(title: title, description: description, buttonTitle: buttonTitle, popBackOnSelect: popBackOnSelect, buttonTapped: buttonTapped) {
                ForEach(options.uniqued(), id: \.self) { option in
                    Button(action: {
                        if isContentLocked {
                            showPaymentView = true
                        } else {
                            if enableMultipleSelection {
                                if let index = selectedOptions.firstIndex(of: option) {
                                    selectedOptions.remove(at: index)
                                } else {
                                    selectedOptions.append(option)
                                }
                            } else {
                                selectedOptions = [option]
                            }
                        }
                    }) {
                        HStack {
                            Text(option)
                            Spacer()
                            if isContentLocked {
                                Image(systemName: "lock.fill")
//                                .font(.bold(size: 18))
//                                .foregroundColor(color.opacity(0.2))
                                //
                            } else if selectedOptions.contains(option) {
                                ZStack {
                                    Circle()
                                        .fill(Color.customBlue)
                                        .frame(width: 25, height: 25)
                                    Image(systemName: "checkmark")
                                        .font(.bold(size: 12))
                                        .foregroundColor(.customWhite)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
