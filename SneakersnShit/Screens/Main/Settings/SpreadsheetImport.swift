//
//  SpreadsheetImportView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/28/21.
//

import SwiftUI

#warning("add import description")
#warning("add revert button")

struct SpreadsheetImportView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @Environment(\.presentationMode) var presentationMode
    @State var spreadsheetURL: String
    @StateObject private var loader = Loader()

    @State private var error: (String, String, String?)? = nil
    @State private var revertImportTapped = false

    init() {
        _spreadsheetURL = State(initialValue: AppStore.default.state.user?.spreadSheetImportUrl ?? "")
    }

    var statusColor: Color {
        switch store.globalState.user?.spreadSheetImportStatus {
        case .none:
            return .customText1
        case .Pending:
            return .customBlue
        case .Processing:
            return .customYellow
        case .Done:
            return .customGreen
        case .Error:
            return .customRed
        }
    }

    @ViewBuilder func statusDescriptionText(for status: User.SpreadSheetImportStatus) -> some View {
        switch status {
        case .Pending:
            Text("We received your import request and will start processing it shortly.")
                .foregroundColor(.customText1)
                .font(.regular(size: 14))
        case .Processing:
            Text("We're working on importing your spreadsheet. Your imported items will soon appear in your inventory.")
                .foregroundColor(.customText1)
                .font(.regular(size: 14))
        case .Done:
            VStack(alignment: .leading, spacing: 5) {
                Text("Spreadsheet import is done. The imported items have been added to your inventory.")
                    .foregroundColor(.customText1)
                    .font(.regular(size: 14))
                HStack(spacing: 5) {
                    Text("Don't like the result?")
                        .foregroundColor(.customText1)
                        .font(.regular(size: 14))
                    Button {
                        revertImportTapped = true
                    } label: {
                        Text("Revert import")
                            .foregroundColor(.customRed)
                            .font(.bold(size: 14))
                            .underline()
                    }
                    Spacer()
                }
            }
        case .Error:
            VStack(alignment: .leading, spacing: 15) {
                Text("We had trouble importing your spreadsheet. Please send us a message at: ")
                    .foregroundColor(.customText1)
                    .font(.regular(size: 14))
                HStack(spacing: 0) {
                    Link("Discord,", destination: URL(string: "https://discord.gg/cQh6VTvXas")!)
                        .foregroundColor(.customBlue)
                        .font(.bold(size: 16))
                    Link(" Twitter ", destination: URL(string: "https://twitter.com/Cop_Deck")!)
                        .foregroundColor(.customBlue)
                        .font(.bold(size: 16))
                    Text("or")
                        .foregroundColor(.customText1)
                        .font(.regular(size: 16))
                    Link(" contact@copdeck.com", destination: URL(string: "mailto:contact@copdeck.com")!)
                        .foregroundColor(.customBlue)
                        .font(.bold(size: 16))
                    Spacer()
                }
            }
        }
    }

    var body: some View {
        let presentAlert = Binding<Bool>(get: { error != nil || revertImportTapped },
                                         set: { new in
                                             if !new {
                                                 error = nil
                                                 revertImportTapped = false
                                             }
                                         })

        VStack(spacing: 8) {
            NavigationBar(title: "Spreadsheet import", isBackButtonVisible: true, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .withDefaultPadding(padding: .top)
            Text("asdsad a d ad as d asd asd as d")
                .foregroundColor(.customText2)
                .font(.regular(size: 14))
                .multilineTextAlignment(.center)
            Spacer()
            VStack(spacing: 20) {
                HStack(spacing: 5) {
                    TextFieldRounded(placeHolder: "Spreadsheet url", style: .gray, text: $spreadsheetURL)
                        .layoutPriority(1)
                    Button {
                        if let url = store.globalState.user?.spreadSheetImportUrl, let status = store.globalState.user?.spreadSheetImportStatus {
                            if spreadsheetURL == url {
                                self.error = ("Error", "You already submitted an import request with this url.", nil)
                                return
                            }
                            switch status {
                            case .Processing:
                                self.error = ("Error",
                                              "Your last import is being processed at the moment. Please wait until it's finished to submit another import request.",
                                              nil)
                                return
                            case .Pending:
                                self.error = ("Are you sure?",
                                              "You have an import request in pending status. Submitting another request will overwrite the current one.",
                                              "Overwrite current request")
                                return
                            case .Error,
                                 .Done:
                                break
                            }
                        }
                        sendImportRequest()
                    } label: {
                        Text("Start import")
                            .font(.bold(size: 14))
                            .foregroundColor(.customWhite)
                            .frame(width: 110, height: Styles.inputFieldHeight)
                            .background(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                                .fill(Color.customBlue))
                    }
                }

                VStack(alignment: .leading, spacing: 15) {
                    if loader.isLoading {
                        CustomSpinner(text: "Sending import request", animate: true)
                    }

                    HStack(spacing: 5) {
                        Text("Your spreadsheet import status:")
                            .foregroundColor(.customText2)
                            .font(.regular(size: 14))
                        Text(store.globalState.user?.spreadSheetImportStatus?.rawValue ?? "Not started")
                            .foregroundColor(statusColor)
                            .font(.bold(size: 14))
                        Spacer()
                    }
                    if let status = store.globalState.user?.spreadSheetImportStatus {
                        statusDescriptionText(for: status)
                    }
                }
            }
            Spacer()
        }
        .withDefaultPadding(padding: .horizontal)
        .alert(isPresented: presentAlert) {
            let title = error?.0 ?? ""
            let description = error?.1 ?? ""
            if revertImportTapped {
                return Alert(title: Text("Are you sure?"),
                             message: Text("This will delete all your items from the last import."),
                             primaryButton: Alert.Button.destructive(Text("Revert"), action: { revertLastImport() }),
                             secondaryButton: .cancel())
            } else if let buttonText = error?.2 {
                return Alert(title: Text(title), message: Text(description), primaryButton: Alert.Button.destructive(Text(buttonText), action: {
                    sendImportRequest()
                }), secondaryButton: .cancel())
            } else {
                return Alert(title: Text(title), message: Text(description), dismissButton: Alert.Button.cancel(Text("Okay")))
            }
        }
        .navigationbarHidden()
    }

    private func revertLastImport() {
        let loader = loader.getLoader()
        store.send(.main(action: .revertLastImport(completion: { error in
            if let error = error {
                self.error = ("Error", error.localizedDescription, nil)
            } else {
                spreadsheetURL = ""
            }
            loader(.success(()))
        })))
    }

    private func sendImportRequest() {
        let loader = loader.getLoader()
        store.send(.main(action: .startSpreadsheetImport(urlString: spreadsheetURL, completion: { error in
            if let error = error {
                self.error = ("Error", error.localizedDescription, nil)
            }
            loader(.success(()))
        })))
    }
}
