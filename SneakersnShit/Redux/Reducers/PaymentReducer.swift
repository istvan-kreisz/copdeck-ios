//
//  PaymentReducer.swift
//  CopDeck
//
//  Created by István Kreisz on 2/13/23.
//

import Foundation
import Combine
import Firebase

func paymentReducer(state: inout AppState,
                    action: PaymentAction,
                    environment: World,
                    completed: ((Result<Void, AppError>) -> Void)?) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .purchase(package):
        Analytics.logEvent("buy_pro", parameters: ["userId": state.user?.id ?? ""])
        return environment.paymentService.purchase(package: package)
            .handleEvents(receiveCompletion: { completion in
                guard case .finished = completion else { return }
                if var user = AppStore.default.state.user {
                    if user.subscription != .pro {
                        user.subscription = .pro
                        AppStore.default.state.user = user
                    }
                }
            })
            .map { _ in AppAction.none }
            .tryCatch {
                Just(AppAction.error(action: .setError(error: $0)))
            }
            .replaceError(with: AppAction.none)
            .eraseToAnyPublisher()
    case let .restorePurchases(completion):
        Analytics.logEvent("restore_purchases", parameters: ["userId": state.user?.id ?? ""])
        environment.dataController.refreshUserSubscriptionStatus(completion: completion)
    case let .showPaymentView(show):
        if show {
            Analytics.logEvent("show_payment_view", parameters: ["userId": state.user?.id ?? ""])
        }
        state.showPaymentView = show
    }
    return Empty(completeImmediately: true).eraseToAnyPublisher()
}
