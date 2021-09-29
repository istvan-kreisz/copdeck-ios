//
//  SpreadsheetImportAdminView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/28/21.
//

import SwiftUI

struct SpreadsheetImportAdminView: View {
    @EnvironmentObject var store: DerivedGlobalStore
    @Environment(\.presentationMode) var presentationMode
    @State var waitlist: [User] = []
    @State private var error: (String, String)? = nil

    @State var userToMarkAsFailed: User?

    @StateObject private var loader = Loader()

    @State var spreadSheetImportStatusFilter = "All"

    func statusColor(for spreadSheetImportStatus: User.SpreadSheetImportStatus?) -> Color {
        switch spreadSheetImportStatus {
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

    var filteredUsers: [User] {
        waitlist.filter { (user: User) in
            spreadSheetImportStatusFilter == "All" || user.spreadSheetImportStatus?.rawValue == spreadSheetImportStatusFilter
        }
    }

    var body: some View {
        let presentErrorAlert = Binding<Bool>(get: { error != nil }, set: { new in error = new ? error : nil })
        let presentMarkAsFailedAlert = Binding<Bool>(get: { userToMarkAsFailed != nil }, set: { new in userToMarkAsFailed = new ? userToMarkAsFailed : nil })

        VStack(spacing: 8) {
            NavigationBar(title: nil, isBackButtonVisible: true, style: .dark) {
                presentationMode.wrappedValue.dismiss()
            }
            .withDefaultPadding(padding: .top)
            .withDefaultPadding(padding: .horizontal)

            Text("Spreadsheet import waitlist")
                .foregroundColor(.customText1)
                .font(.bold(size: 22))
                .padding(.bottom, 25)

            Picker(selection: $spreadSheetImportStatusFilter,
                   label: Text("")) {
                ForEach(["All"] + User.SpreadSheetImportStatus.allCases.map(\.rawValue), id: \.self) { (option: String) in
                    Text(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 10)
            .padding(.horizontal, 15)

            List {
                if loader.isLoading {
                    CustomSpinner(text: "Loading", animate: true)
                }

                ForEach(filteredUsers) { (user: User) in
                    VStack(spacing: 10) {
                        if let spreadSheetImportDate = user.spreadSheetImportDate {
                            UserDetailView(name: "submitted", value: spreadSheetImportDate.asDateFormat1, showCopyButton: false)
                        }
                        if let username = user.name {
                            UserDetailView(name: "username", value: username)
                        }
                        UserDetailView(name: "user id", value: user.id)
                        if let spreadSheetImportUrl = user.spreadSheetImportUrl {
                            UserDetailView(name: "spreadsheet url", value: spreadSheetImportUrl)
                        }
                        if let spreadSheetImporter = user.spreadSheetImporter {
                            UserDetailView(name: "imported by",
                                           value: DebugSettings.shared.adminName(for: spreadSheetImporter) ?? "",
                                           showCopyButton: false,
                                           color: spreadSheetImporter == DebugSettings.shared.istvanId ? .customBlue : .customOrange)
                        }
                        if let spreadSheetImportStatus = user.spreadSheetImportStatus {
                            UserDetailView(name: "import status",
                                           value: spreadSheetImportStatus.rawValue,
                                           showCopyButton: false,
                                           color: statusColor(for: spreadSheetImportStatus))
                        }
                        if let spreadSheetImportError = user.spreadSheetImportError {
                            UserDetailView(name: "error message", value: spreadSheetImportError, showCopyButton: false, color: .customRed)
                        }

                        HStack(spacing: 10) {
                            Spacer()
                            switch user.spreadSheetImportStatus {
                            case .Pending:
                                Button {
                                    updateSpreadsheetImportStatus(userId: user.id, newStatus: .Processing, errorMessage: nil)
                                } label: {
                                    Text("Start importing")
                                        .font(.bold(size: 18))
                                        .foregroundColor(.customBlue)
                                }
                                Spacer()
                                Button {
                                    userToMarkAsFailed = user
                                } label: {
                                    Text("Mark as failed")
                                        .font(.bold(size: 18))
                                        .foregroundColor(.customRed)
                                }
                            case .Processing:
                                Button {
                                    runImport(userId: user.id)
                                } label: {
                                    Text("Run import")
                                        .font(.bold(size: 18))
                                        .foregroundColor(.customBlue)
                                }
                                Spacer()
                                Button {
                                    userToMarkAsFailed = user
                                } label: {
                                    Text("Mark as failed")
                                        .font(.bold(size: 18))
                                        .foregroundColor(.customRed)
                                }
                            default:
                                EmptyView()
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 5)
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .onAppear {
            refreshWaitlist()
        }
        .alert(isPresented: presentErrorAlert) {
            let title = error?.0 ?? ""
            let description = error?.1 ?? ""
            return Alert(title: Text(title), message: Text(description), dismissButton: Alert.Button.cancel(Text("Okay")))
        }
        .withTextFieldPopup(isShowing: presentMarkAsFailedAlert,
                            title: "Mark as failed",
                            subtitle: nil,
                            placeholder: "Description",
                            actionTitle: "Send") { errorMessage in
            if let user = userToMarkAsFailed {
                updateSpreadsheetImportStatus(userId: user.id, newStatus: .Error, errorMessage: errorMessage)
            }
        }
        .navigationbarHidden()
    }

    private func updateSpreadsheetImportStatus(userId: String, newStatus: User.SpreadSheetImportStatus, errorMessage: String?) {
        store.send(.main(action: .updateSpreadsheetImportStatus(importedUserId: userId,
                                                                spreadSheetImportStatus: newStatus,
                                                                spreadSheetImportError: errorMessage,
                                                                completion: updateWaitlist)))
    }

    private func runImport(userId: String) {
        store.send(.main(action: .runImport(importedUserId: userId, completion: updateWaitlist)))
    }

    private func updateWaitlist(result: Result<User, Error>) {
        switch result {
        case let .success(user):
            if let userIndex = waitlist.firstIndex(where: { $0.id == user.id }) {
                waitlist[userIndex] = user
            }
        case let .failure(error):
            self.error = ("Error", error.localizedDescription)
        }
    }

    private func refreshWaitlist() {
        let loader = loader.getLoader()
        store.send(.main(action: .getSpreadsheetImportWaitlist(completion: { result in
            switch result {
            case let .success(users):
                waitlist = users
            case let .failure(error):
                self.error = ("Error", error.localizedDescription)
            }
            loader(.success(()))

        })))
    }
}
