//
//  SpreadsheetImportView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/28/21.
//

import SwiftUI

#warning("add import description")

struct SpreadsheetImportView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @Environment(\.presentationMode) var presentationMode
    @State var spreadsheetURL: String = ""
    @StateObject private var loader = Loader()

    @State private var error: (String, String, String?)? = nil

    var statusColor: Color {
        switch store.globalState.user?.spreadSheetImport?.status {
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

    @ViewBuilder func statusDescriptionText(for status: User.SpreadsheetImport.SpreadSheetImportStatus) -> some View {
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
            Text("Spreadsheet import is done. The imported items have been added to your inventory.")
                .foregroundColor(.customText1)
                .font(.regular(size: 14))
        case .Error:
            VStack(spacing: 0) {
                Text("We had trouble importing your spreadsheet. Please send us a message at: ")
                    .foregroundColor(.customText1)
                    .font(.regular(size: 14))
                HStack(spacing: 0) {
                    Link("Discord", destination: URL(string: "https://discord.gg/cQh6VTvXas")!)
                        .foregroundColor(.customText1)
                        .font(.regular(size: 14))
                    Link(" Twitter ", destination: URL(string: "https://twitter.com/Cop_Deck")!)
                        .foregroundColor(.customText1)
                        .font(.regular(size: 14))
                    Text("or")
                        .foregroundColor(.customText1)
                        .font(.regular(size: 14))
                    Link(" contact@copdeck.com", destination: URL(string: "mailto:contact@copdeck.com")!)
                        .foregroundColor(.customText1)
                        .font(.regular(size: 14))
                }
            }
        }
    }

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })

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
                        if let currentImport = store.globalState.user?.spreadSheetImport, let url = currentImport.url, let status = currentImport.status {
                            if currentImport.url == url {
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
                        Text(store.globalState.user?.spreadSheetImport?.status?.rawValue ?? "Not started")
                            .foregroundColor(statusColor)
                            .font(.bold(size: 14))
                        Spacer()
                    }
                    if let status = store.globalState.user?.spreadSheetImport?.status {
                        statusDescriptionText(for: status)
                    }
                }
            }
            Spacer()
        }
        .withDefaultPadding(padding: .horizontal)
        .alert(isPresented: presentErrorAlert) {
            let title = error?.0 ?? ""
            let description = error?.1 ?? ""
            if let buttonText = error?.2 {
                return Alert(title: Text(title), message: Text(description), primaryButton: Alert.Button.destructive(Text(buttonText), action: {
                    sendImportRequest()
                }), secondaryButton: .cancel())
            } else {
                return Alert(title: Text(title), message: Text(description), dismissButton: Alert.Button.cancel(Text("Okay")))
            }
        }
        .navigationbarHidden()
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
