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
    @State private var sortOption: String
    @State private var groupByModels: Bool

    @Binding private var isPresented: Bool

    init(settings: CopDeckSettings, isPresented: Binding<Bool>) {
        self._settings = State(initialValue: settings)
        self._soldStatus = State(initialValue: settings.filters.soldStatus.rawValue)
        self._sortOption = State(initialValue: settings.filters.sortOption.name)
        self._groupByModels = State(initialValue: settings.filters.groupByModels)
        self._isPresented = isPresented
    }

    private func selectSoldStatus() {
        if let soldStatus = Filters.SoldStatusFilter(rawValue: soldStatus),
           settings.filters.soldStatus != soldStatus {
            settings.filters.soldStatus = soldStatus
        }
    }

    private func selectSortOption() {
        if let sortOption = Filters.SortOption.initWith(name: sortOption),
           settings.filters.sortOption != sortOption {
            settings.filters.sortOption = sortOption
        }
    }

    private func toggleGroupByModels(newValue: Bool) {
        if settings.filters.groupByModels != newValue {
            settings.filters.groupByModels = newValue
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

                ListSelectorMenu(title: "Sort by",
                                 selectorScreenTitle: "Sort by",
                                 buttonTitle: "Select option",
                                 options: Filters.SortOption.allCases.map(\.name),
                                 selectedOption: $sortOption,
                                 buttonTapped: selectSortOption)

                HStack {
                    Text("Group by models")
                        .layoutPriority(2)
                    Spacer()
                    Toggle("", isOn: $groupByModels)
                }
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
        .onChange(of: groupByModels) { newValue in
            toggleGroupByModels(newValue: newValue)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.light)
    }
}
