//
//  FiltersModal.swift
//  SneakersnShit
//
//  Created by István Kreisz on 8/21/21.
//

import SwiftUI
import Combine

struct FiltersModal: View {
    @EnvironmentObject var store: AppStore
    @State private var settings: CopDeckSettings

    @State private var soldStatus: String

    @Binding private var isPresented: Bool

    init(settings: CopDeckSettings, isPresented: Binding<Bool>) {
        self._settings = State(initialValue: settings)
        self._soldStatus = State(initialValue: settings.filters.soldStatus.rawValue)
        self._isPresented = isPresented
    }

    private func selectSoldStatus() {
        if let soldStatus = Filters.SoldStatusFilter(rawValue: soldStatus),
           settings.filters.soldStatus != soldStatus {
            settings.filters.soldStatus = soldStatus
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Text("Filters")
                    .foregroundColor(.customText1)
                    .font(.bold(size: 35))
                    .withDefaultPadding(padding: [.top])

                ListSelectorMenu(title: "Sold status",
                                 selectorScreenTitle: "Select filter",
                                 buttonTitle: "Select filter",
                                 options: Filters.SoldStatusFilter.allCases.map(\.rawValue),
                                 selectedOption: $soldStatus,
                                 buttonTapped: selectSoldStatus)
            }
            .hideKeyboardOnScroll()
            .navigationbarHidden()
            .withFloatingButton(button: RoundedButton<EmptyView>(text: "Save Filters",
                                                                 width: 200,
                                                                 height: 60,
                                                                 color: .customBlack,
                                                                 accessoryView: nil) {
                    store.send(.main(action: .updateSettings(settings: settings)))
                    isPresented = false
                })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.light)
    }
}
