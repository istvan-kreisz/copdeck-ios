//
//  PaymentView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/21/21.
//

import SwiftUI
import Purchases

struct PaymentView: View {
    enum ViewType {
        case trial(Purchases.Package)
        case subscribe
    }

    enum BulletpointStyle {
        case checkmark
        case dot
    }

    @EnvironmentObject var store: DerivedGlobalStore

    let viewType: ViewType
    var trialPackage: Purchases.Package? {
        switch viewType {
        case let .trial(package):
            return package
        case .subscribe:
            return nil
        }
    }

    @Binding var show: Bool

    @State var present = false
    @State var showContactView = false
    @State var showReferralCodeView = false
    
    @State private var alert: (String, String)? = nil

    static let privacyPolicyString: NSMutableAttributedString = {
        let string = NSMutableAttributedString(string: "Before joining, please read our Privacy Policy and Terms & Conditions")
        string.addAttributes([.foregroundColor: UIColor(Color.customText2), .font: UIFont.regular(size: 14)],
                             range: NSRange.init(location: 0, length: string.length))
        string.setAsLink(textToFind: "Privacy Policy", linkURL: "https://copdeck.com/privacy")
        string.setAsLink(textToFind: "Terms & Conditions", linkURL: "https://copdeck.com/termsandconditions")
        return string
    }()

    static let restorePurchasesString: NSMutableAttributedString = {
        let string = NSMutableAttributedString(string: "If you're already a CopDeck member, Restore Purchases to regain access.")
        string.addAttributes([.foregroundColor: UIColor(Color.customText2), .font: UIFont.regular(size: 14)],
                             range: NSRange.init(location: 0, length: string.length))
        string.setAsLink(textToFind: "Restore Purchases", linkURL: "https://copdeck.com/")
        return string
    }()

    private func bulletPoint(text: String, bulletpointStyle: BulletpointStyle) -> some View {
        HStack(alignment: .top, spacing: 5) {
            Image(systemName: bulletpointStyle == .checkmark ? "checkmark" : "app.fill")
                .font(.bold(size: bulletpointStyle == .checkmark ? 18 : 20))
                .foregroundColor(Color.customBlue)
                .padding(.top, 3)

            Text(text)
                .font(.regular(size: bulletpointStyle == .checkmark ? 18 : 20))
                .foregroundColor(.customText1)
        }
    }

    var discountPercentage: Int? {
        guard let monthlyPackage = store.globalState.packages?.monthlyPackage,
              let yearlyPackage = store.globalState.packages?.yearlyPackage
        else { return nil }
        let yearlyPrice = Double(truncating: yearlyPackage.product.price)
        let monthlyPrice = Double(truncating: monthlyPackage.product.price)
        let percentage = 100 * ((monthlyPrice * 12.0) - yearlyPrice) / (monthlyPrice * 12.0)
        return Int(round(percentage))
    }

    var body: some View {
        let presentAlert = Binding<Bool>(get: { alert != nil }, set: { new in alert = new ? alert : nil })
        let showSheet = Binding<Bool>(get: { showReferralCodeView || showContactView },
                                      set: { new in
                                          if !new {
                                              showReferralCodeView = false
                                              showContactView = false
                                          }
                                      })

        ZStack {
            Color.customWhite.edgesIgnoringSafeArea(.all)

            if present {
                ZStack {
                    Color.customWhite.edgesIgnoringSafeArea(.all)
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 30) {
                            ZStack(alignment: .center) {
                                HStack(alignment: .center, spacing: 5) {
                                    #warning("make bold logo")
                                    Image("logo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 45)
                                    Text("CopDeck Pro")
                                        .font(.bold(size: 25))
                                        .foregroundColor(.customText1)
                                }
                                .centeredHorizontally()
                                .padding(.vertical, 10)
                                .padding(.bottom, 5)
                                Button {
                                    show = false
                                } label: {
                                    Text("Exit")
                                        .font(.bold(size: 20))
                                        .foregroundColor(.customText1)
                                        .underline()
                                }
                                .rightAligned()
                            }

                            if let trialPackage = trialPackage {
                                if let monthlyPriceString = trialPackage.priceString(for: .monthly) {
                                    Text("\(trialPackage.terms), then \(monthlyPriceString) per month")
                                        .font(.bold(size: 25))
                                        .foregroundColor(.customText1)
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 10) {
                                    if let monthlyPackage = store.globalState.packages?.monthlyPackage,
                                       let monthlyPriceString = monthlyPackage.priceString(for: .monthly) {
                                        Text("\(monthlyPackage.terms), then \(monthlyPriceString) per month")
                                            .font(.bold(size: 20))
                                            .foregroundColor(.customText1)
                                    }
                                    if let yearlyPackage = store.globalState.packages?.yearlyPackage,
                                       let yearlyPriceString = yearlyPackage.priceString(for: .annual) {
                                        Text("OR")
                                            .font(.bold(size: 20))
                                            .foregroundColor(.customText1)
                                        Text("\(yearlyPackage.terms), then \(yearlyPriceString) per year")
                                            .font(.bold(size: 20))
                                            .foregroundColor(.customText1)
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                bulletPoint(text: "Compare prices on the biggest sneaker reselling sites", bulletpointStyle: .checkmark)
                                bulletPoint(text: "Track your inventory", bulletpointStyle: .checkmark)
                                bulletPoint(text: "Follow other sneakerheads", bulletpointStyle: .checkmark)
                                bulletPoint(text: "Share your inventory everywhere with just a few clicks", bulletpointStyle: .checkmark)
                            }
                            .padding(.bottom, 10)

                            Text("How to get started with CopDeck:")
                                .font(.bold(size: 25))
                                .foregroundColor(.customText1)

                            VStack(alignment: .leading, spacing: 14) {
                                bulletPoint(text: "Import your inventory using our spreadsheet import feature or just add your sneakers manually.",
                                            bulletpointStyle: .dot)
                                bulletPoint(text: "Find where to buy & sell your shoes using CopDeck's price comparison.", bulletpointStyle: .dot)
                                bulletPoint(text: "Share your items on CopDeck & on the web with the stack sharing feature.", bulletpointStyle: .dot)
                                bulletPoint(text: "...", bulletpointStyle: .dot)
                                bulletPoint(text: "Profit $$$", bulletpointStyle: .dot)
                            }

                            if let trialPackage = trialPackage {
                                VStack(alignment: .center, spacing: 4) {
                                    if let weeklyPriceString = trialPackage.priceString(for: .weekly) {
                                        Text("Just \(weeklyPriceString) per week")
                                            .font(.semiBold(size: 23))
                                            .foregroundColor(.customText1)
                                    }

                                    Text("Cancel anytime, billed monthly")
                                        .font(.regular(size: 18))
                                        .foregroundColor(Color.customText1.opacity(0.8))
                                }
                                .padding(12)
                                .frame(width: UIScreen.screenWidth - Styles.horizontalMargin * 2 - 6)
                                .background(RoundedRectangle(cornerRadius: Styles.cornerRadius).stroke(Color.customBlue, lineWidth: 3))
                                .centeredHorizontally()
                                .padding(.vertical, 10)
                            }

                            VStack(alignment: .leading, spacing: 30) {
                                Image("logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80)
                                    .centeredHorizontally()

                                Text("Take your reselling business to the next level with CopDeck!")
                                    .font(.bold(size: 28))
                                    .foregroundColor(.customText1)
                                    .multilineTextAlignment(.center)
                                    .centeredHorizontally()
                            }
                            .padding(.bottom, 20)

                            VStack(spacing: 10) {
                                if trialPackage == nil {
                                    HStack(alignment: .center, spacing: 10) {
                                        if let monthlyPackage = store.globalState.packages?.monthlyPackage {
                                            PackageCellView(color: .customBlue,
                                                            discountPercentage: nil,
                                                            package: monthlyPackage) { package in
                                                store.send(.paymentAction(action: .purchase(package: monthlyPackage)))
                                            }
                                        }
                                        if let yearlyPackage = store.globalState.packages?.yearlyPackage {
                                            PackageCellView(color: .customPurple,
                                                            discountPercentage: discountPercentage,
                                                            package: yearlyPackage) { package in
                                                store.send(.paymentAction(action: .purchase(package: yearlyPackage)))
                                            }
                                        }
                                    }
                                    .frame(width: 300)
                                    .centeredHorizontally()
                                    .padding(.bottom, 30)
                                }

                                VStack(alignment: .center, spacing: 10) {
                                    Text("Have questions?")
                                        .font(.bold(size: 18))
                                        .foregroundColor(.customText1)
                                    Button {
                                        showContactView = true
                                    } label: {
                                        Text("Message us")
                                            .font(.bold(size: 14))
                                            .foregroundColor(.customWhite)
                                            .padding(10)
                                            .background(RoundedRectangle(cornerRadius: Styles.cornerRadius).fill(Color.customBlue))
                                    }
                                }

                                if store.globalState.user?.membershipInfo?.referralCodeUsed == nil {
                                    VStack(alignment: .center, spacing: 10) {
                                        Text("Apply referral code")
                                            .font(.bold(size: 18))
                                            .foregroundColor(.customText1)
                                        Button {
                                            showReferralCodeView = true
                                        } label: {
                                            Text("Add code")
                                                .font(.bold(size: 14))
                                                .foregroundColor(.customWhite)
                                                .padding(10)
                                                .background(RoundedRectangle(cornerRadius: Styles.cornerRadius).fill(Color.customBlue))
                                        }
                                    }
                                }

                                DiscountsView(membershipInfo: store.globalState.user?.membershipInfo)
                                    .padding(.top, 20)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    AttributedText(Self.privacyPolicyString)
                                        .frame(height: 42)
                                    AttributedText(Self.restorePurchasesString) { _ in
                                        restorePurchases()
                                    }
                                    .frame(height: 42)
                                }
                                .frame(width: UIScreen.screenWidth - 2 * Styles.horizontalMargin)
                                .buttonStyle(.plain)
                            }
                            .buttonStyle(.plain)
                            
                            if case .subscribe = viewType {
                                Spacer(minLength: UIApplication.shared.safeAreaInsets().bottom == 0 ? 30 : UIApplication.shared.safeAreaInsets().bottom)
                            } else {
                                Spacer(minLength: UIApplication.shared.safeAreaInsets().bottom == 0 ? 85 : UIApplication.shared.safeAreaInsets().bottom + 55)
                            }
                        }
                    }
                    .withDefaultPadding(padding: .horizontal)
                    .withDefaultPadding(padding: .top)
                    .navigationbarHidden()
                    if let trialPackage = trialPackage {
                        VStack {
                            Spacer()

                            VStack(alignment: .center, spacing: 7, content: {
                                Button {
                                    subscribe()
                                } label: {
                                    Text(trialPackage.termsFull)
                                        .font(.semiBold(size: 20))
                                        .foregroundColor(.customWhite)
                                        .padding(15)
                                        .frame(width: UIScreen.screenWidth - Styles.horizontalMargin * 2)
                                        .background(RoundedRectangle(cornerRadius: Styles.cornerRadius).fill(Color.customBlue))
                                }

                                if let monthlyPrice = trialPackage.priceString(for: .monthly) {
                                    Text("Then only \(monthlyPrice) per month, billed \(trialPackage.duration)ly")
                                        .font(.regular(size: 16))
                                        .foregroundColor(.customText2)
                                }
                            })
                                .padding(.top, 15)
                                .padding(.bottom, UIApplication.shared.safeAreaInsets().bottom + 10)
                                .frame(width: UIScreen.screenWidth)
                                .background(Color.customWhite)
                                .withDefaultShadow()
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                present = true
            }
        }
        .sheet(isPresented: showSheet) {
            if showContactView {
                ContactView()
            } else {
                ReferralCodeView()
            }
        }
        .alert(isPresented: presentAlert) {
            Alert(title: Text(alert?.0 ?? "Ooops"), message: Text(alert?.1 ?? "Unknown Error"), dismissButton: .default(Text("OK")))
        }
    }

    private func subscribe() {
        guard let trialPackage = trialPackage else { return }
        store.send(.paymentAction(action: .purchase(package: trialPackage)))
    }

    private func restorePurchases() {
        store.send(.paymentAction(action: .restorePurchases(completion: { result in
            switch result {
            case let .failure(error):
                alert = (error.title, error.message)
            case .success:
                alert = ("Success", "Your purchases have been restored.")
            }
        })))
    }
}
