//
//  SpreadsheetImportView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/28/21.
//

import SwiftUI

struct SpreadsheetImportView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @Environment(\.presentationMode) var presentationMode
    @State var spreadsheetURL: String
    @StateObject private var loader = Loader()

    @State private var error: (String, String, String?)? = nil
    @State private var revertImportTapped = false

    init() {
        _spreadsheetURL = State(initialValue: AppStore.default.state.user?.spreadsheetImport?.url ?? "")
    }

    var statusColor: Color {
        switch store.globalState.user?.spreadsheetImport?.status {
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

        VerticalListView(bottomPadding: 0, spacing: 8, listRowStyling: .color(.customWhite)) {
            NavigationBar(title: "Spreadsheet import", isBackButtonVisible: true, titleFontSize: .large, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 30)

            Text("Please note that the imported items won't replace your current inventory, but will be added to it, so you won't lose any data. You'll also have the option to revert the import if you don't like the result.")
                .foregroundColor(.customText2)
                .font(.regular(size: 18))
                .multilineTextAlignment(.leading)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                    .stroke(Color.customBlue, lineWidth: 2)
                    .background(Color.customBlue.opacity(0.1).cornerRadius(Styles.cornerRadius)))

                .padding(.bottom, 5)
                .layoutPriority(2)

            VStack(alignment: .leading, spacing: 12) {
                Text("1. If you're spreadhsheet is not in Google Sheet: Copy your spreadsheets into a new Google Sheet document.")
                    .foregroundColor(.customText2)
                    .font(.regular(size: 18))
                    .multilineTextAlignment(.leading)
                    .layoutPriority(2)
                VStack(alignment: .leading, spacing: 0) {
                    Text("2. In the share menu change the sharing permissions to \"Anyone with the link\" with \"Viewer\" access.")
                        .foregroundColor(.customText2)
                        .font(.regular(size: 18))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .layoutPriority(3)
                    if let url = URL(string: "https://help.tillerhq.com/en/articles/432685-sharing-and-permissions-in-google-sheets") {
                        Link("More info", destination: url)
                            .foregroundColor(.customBlue)
                            .layoutPriority(2)
                    }
                }
                .layoutPriority(3)
                Text("3. Copy & paste the share link below and tap \"Start Import\".")
                    .foregroundColor(.customText2)
                    .font(.regular(size: 18))
                    .multilineTextAlignment(.leading)
                    .layoutPriority(2)
                Text("4. That's it! \(store.globalState.remoteConfig?.spreadsheetImportNotice ?? "")")
                    .foregroundColor(.customText2)
                    .font(.regular(size: 18))
                    .multilineTextAlignment(.leading)
                    .layoutPriority(2)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
            .layoutPriority(3)

            VStack(spacing: 20) {
                HStack(spacing: 5) {
                    TextFieldRounded(placeHolder: "Spreadsheet url", style: .gray, text: $spreadsheetURL, addClearButton: true)
                        .layoutPriority(2)
                    Button {
                        guard !store.globalState.isContentLocked else { return }
                        if let url = store.globalState.user?.spreadsheetImport?.url, let status = store.globalState.user?.spreadsheetImport?.status {
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
                        Text(store.globalState.isContentLocked ? "Unlock with Pro!" : "Start import")
                            .font(.bold(size: store.globalState.isContentLocked ? 12 : 14))
                            .foregroundColor(.customWhite)
                            .frame(width: 110, height: Styles.inputFieldHeight)
                            .background(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                                .fill(Color.customBlue))
                    }
                    .layoutPriority(2)
                }
                .layoutPriority(2)

                VStack(alignment: .leading, spacing: 15) {
                    if loader.isLoading {
                        CustomSpinner(text: "Sending import request", animate: true)
                    }

                    HStack(spacing: 5) {
                        Text("Your spreadsheet import status:")
                            .foregroundColor(.customText2)
                            .font(.regular(size: 14))
                        Text(store.globalState.user?.spreadsheetImport?.status?.rawValue ?? "Not started")
                            .foregroundColor(statusColor)
                            .font(.bold(size: 14))
                        Spacer()
                    }
                    if let errorMessage = store.globalState.user?.spreadsheetImport?.error {
                        Text("Error message: " + errorMessage)
                            .foregroundColor(.customRed)
                            .font(.bold(size: 14))
                            .padding(.bottom, 10)
                    }
                    if let status = store.globalState.user?.spreadsheetImport?.status {
                        statusDescriptionText(for: status)
                    }
                }
                .layoutPriority(2)
            }
            .buttonStyle(.plain)
            .layoutPriority(2)
            Spacer()
        }
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
