//
//  DiscountsView.swift
//  CopDeck
//
//  Created by István Kreisz on 10/28/21.
//

import SwiftUI

struct DiscountsView: View {
    let membershipInfo: User.MembershipInfo?

    var referralCodeInfo: (code: String, name: String, discount: String)? {
        guard let referralCode = membershipInfo?.referralCodeUsed,
              let referralCodeName = membershipInfo?.referralCodeName,
              let referralCodeDiscount = membershipInfo?.referralCodeDiscount
        else { return nil }
        return (referralCode, referralCodeName, referralCodeDiscount)
    }

    var hasDiscounts: Bool {
        (referralCodeInfo != nil) || (membershipInfo?.isBetaTester == true)
    }

    var totalDiscount: String? {
        var discount: Int?
        if let referralCodeInfo = referralCodeInfo {
            discount = Int(referralCodeInfo.discount)
        }
        if membershipInfo?.isBetaTester == true {
            if let d = discount {
                discount = max(DefaultPaymentService.iosBetaTesterDiscount.value, d)
            } else {
                discount = DefaultPaymentService.iosBetaTesterDiscount.value
            }
        }
        return discount.map { "\($0)" }
    }

    var body: some View {
        if hasDiscounts {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Your discounts:")
                        .foregroundColor(.customText1)
                        .font(.bold(size: 18))
                        .padding(.bottom, 10)
                    Spacer()
                }

                if let referralCodeInfo = referralCodeInfo {
                    Text("• Referral code: \(referralCodeInfo.code) (\(referralCodeInfo.name), \(referralCodeInfo.discount)% OFF)")
                        .foregroundColor(.customText1)
                        .multilineTextAlignment(.leading)
                        .font(.regular(size: 15))
                        .fixedSize(horizontal: false, vertical: true)
                }
                if membershipInfo?.isBetaTester == true {
                    Text("• iOS Beta Tester (\(DefaultPaymentService.iosBetaTesterDiscount.valueString)% OFF)")
                        .foregroundColor(.customText1)
                        .font(.regular(size: 15))
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let totalDiscount = totalDiscount {
                    Text("• Total: \(totalDiscount)% OFF")
                        .foregroundColor(.customText1)
                        .font(.bold(size: 15))
                }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .stroke(Color.customBlue, lineWidth: 2)
                .background(Color.customBlue.opacity(0.1).cornerRadius(Styles.cornerRadius)))
            .padding(.horizontal, 3)
        }
    }
}
