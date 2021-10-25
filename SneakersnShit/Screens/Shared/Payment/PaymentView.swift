//
//  PaymentView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/21/21.
//

import SwiftUI

struct PaymentView: View {
    enum BulletpointStyle {
        case checkmark
        case dot
    }

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

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
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

                    #warning("replace hardcoded value")
                    Text("14 days free, then $9.99 per month")
                        .font(.bold(size: 30))
                        .foregroundColor(.customText1)

//                Text("Only $2.49 per week, that's cheaper than a ...")
//                    .font(.semiBold(size: 22))
//                    .foregroundColor(.customText1)

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

                    Button {
                        subscribe()
                    } label: {
                        VStack(alignment: .center, spacing: 4) {
                            Text("Just $2.49 per week")
                                .font(.semiBold(size: 23))
                                .foregroundColor(.customWhite)

                            Text("Cancel anytime, billed monthly")
                                .font(.regular(size: 18))
                                .foregroundColor(Color.customWhite.opacity(0.8))
                        }
                        .padding(12)
                        .frame(width: UIScreen.screenWidth - Styles.horizontalMargin * 2)
                        .background(RoundedRectangle(cornerRadius: Styles.cornerRadius).fill(Color.customBlue))
                    }
                    .padding(.vertical, 10)

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

                    VStack(alignment: .leading, spacing: 1) {
                        AttributedText(Self.privacyPolicyString)
                            .frame(height: 42)
                        AttributedText(Self.restorePurchasesString) { link in
                            #warning("restore purchases")
                        }
                            .frame(height: 42)
                    }
                    Spacer(minLength: UIApplication.shared.safeAreaInsets().bottom + 55)
                }
            }
            .withDefaultPadding(padding: .horizontal)
            .withDefaultPadding(padding: .top)
            .navigationbarHidden()
            VStack {
                Spacer()

                VStack(alignment: .center, spacing: 7, content: {
                    Button {
                        subscribe()
                    } label: {
                        Text("Start your 14 day free trial")
                            .font(.semiBold(size: 20))
                            .foregroundColor(.customWhite)
                            .padding(15)
                            .frame(width: UIScreen.screenWidth - Styles.horizontalMargin * 2)
                            .background(RoundedRectangle(cornerRadius: Styles.cornerRadius).fill(Color.customBlue))
                    }

                    Text("Then only $9.99 per month, billed monthly")
                        .font(.regular(size: 16))
                        .foregroundColor(.customText2)
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

    private func subscribe() {}

    private func restorePurchases() {}
}
