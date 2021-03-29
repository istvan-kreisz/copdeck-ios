//
//  HomeView.swift
//  SneakersnShit
//
//  Created by István Kreisz on 1/30/21.
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var store: Store<MainState, MainAction, Main>

    let colors: [Color] = [.red, .yellow, .green, .purple, .orange]

    @State var searchText = ""

    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    TextField("Search", text: $searchText)
                        .padding()

                    ForEach(store.state.searchResults ?? []) { item in
                        HStack {
                            Image(systemName: "tray.2")
                                .frame(width: 80, height: 80)
                            VStack {
                                HStack {
                                    Text((item.stockxStoreInfo ?? item.storeInfo.first)?.name ?? "")
                                        .font(.semiBold(size: 13))
                                    Spacer()
                                }
                                HStack(spacing: 10) {
                                    ForEach(item.storeInfo) { storeInfo in
                                        Text(storeInfo.store.rawValue)
                                            .font(.regular(size: 12))
                                    }
                                    Spacer()
                                }
                            }
                            Button(action: {
                                self.addToInventory(item: item)
                            }) {
                                Text("Add")
                                    .font(.bold(size: 18))
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 15)
                        }.onTapGesture {
                            print("ayyyy")
                        }
                    }
                    .withDefaultPadding()

//                ZStack {
//                    Color.customLightGray3
//                    VStack {
//                        Text("Portfolio")
//                            .font(.bold(size: 16))
//                            .withDefaultPadding(padding: .top)
//
//                        ForEach(store.state.userStocks ?? []) { stock in
//                            HStack {
//                                AvatarView(imageURL: "")
//                                VStack(alignment: .leading) {
//                                    Text(stock.id)
//                                        .font(.regular(size: 16))
//                                    Text("+4%")
//                                        .font(.regular(size: 16))
//                                        .foregroundColor(.customGreen)
//                                }
//                                Spacer()
//                                Text("$\(stock.price)")
//                                    .font(.bold(size: 14))
//                            }
//                            .withDefaultPadding(padding: [.leading, .trailing])
//                        }
//                    }
//                }
//                .edgesIgnoringSafeArea(.all)
                }
            }
        }
        .onChange(of: searchText) { searchText in
            store.send(.search(searchTerm: searchText))
        }
    }

    func addToInventory(item: Item) {
        print("yoooo")
//        store.send(.)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let store = AppStore(initialState: .mockAppState,
                             reducer: appReducer,
                             environment: World(isMockInstance: true))
        return Group {
            HomeView()
                .environmentObject(store
                    .derived(deriveState: \.mainState,
                             deriveAction: AppAction.main,
                             derivedEnvironment: store.environment.main))
        }
    }
}
