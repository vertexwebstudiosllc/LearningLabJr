import Foundation
import Combine
import StoreKit
import SwiftUI

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published var products: [Product] = []
    @Published var hasPremium: Bool = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var statusMessage: String?

    private let productIDs: Set<String> = [
        "com.learninglabjr.premium.monthly"
    ]

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updateCustomerProductStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProducts() async {
        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            products = try await Product.products(for: productIDs)
            statusMessage = nil
        } catch {
            statusMessage = "We couldn't reach the App Store. Please try again when connected."
        }
    }

    func purchase(_ product: Product) async {
        guard !isPurchasing else { return }
        isPurchasing = true
        statusMessage = nil
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)

                await updateCustomerProductStatus()
                await transaction.finish()

            case .userCancelled:
                break

            case .pending:
                statusMessage = "Your purchase is waiting for approval. Games will unlock when it is approved."

            @unknown default:
                break
            }
        } catch {
            statusMessage = "The purchase couldn't be completed. You can try again or restore an existing purchase."
        }
    }

    func restorePurchases() async {
        guard !isPurchasing else { return }
        isPurchasing = true
        statusMessage = nil
        defer { isPurchasing = false }
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
            statusMessage = hasPremium ? "Your Premium access is restored." : "No active Premium subscription was found for this Apple Account."
        } catch {
            statusMessage = "Purchases couldn't be restored. Please check your connection and try again."
        }
    }

    func updateCustomerProductStatus() async {
        var premiumActive = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                guard productIDs.contains(transaction.productID) else {
                    continue
                }

                // StoreKit includes subscriptions in billing grace period here.
                // A past transaction expiration date must not revoke that access.
                if transaction.revocationDate == nil { premiumActive = true }
            } catch {
                print("Unverified transaction")
            }
        }

        hasPremium = premiumActive
        if premiumActive { statusMessage = nil }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await MainActor.run {
                        try StoreManager.shared.checkVerified(result)
                    }

                    await StoreManager.shared.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}

struct PremiumParentGateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = StoreManager.shared
    @State private var unlocked = false

    var body: some View {
        Group {
            if unlocked {
                PremiumPaywallView()
            } else {
                ParentChallengeView(onSuccess: { unlocked = true }, onCancel: { dismiss() })
            }
        }
        .onChange(of: store.hasPremium) { _, premium in
            if premium { dismiss() }
        }
    }
}

struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storeManager = StoreManager.shared

    var body: some View {
        ScrollView {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 52, weight: .bold))
                .foregroundColor(Color(red: 0.96, green: 0.62, blue: 0.18))

            Text("Unlock Premium Games")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            Text("Unlock six additional phonics and word-play activities. The other activities stay available without a subscription.")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let product = storeManager.products.first {
                Button {
                    Task {
                        await storeManager.purchase(product)
                    }
                } label: {
                    Text("Subscribe · \(product.displayPrice) / \(billingPeriod(product))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.10, green: 0.58, blue: 0.78))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .disabled(storeManager.isPurchasing)
            } else {
                Text(storeManager.isLoadingProducts ? "Loading subscription…" : "Subscription unavailable")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)

                Button("Try Again") {
                    Task {
                        await storeManager.loadProducts()
                    }
                }
                .font(.system(size: 17, weight: .bold, design: .rounded))
            }

            if let message = storeManager.statusMessage {
                Text(message).font(.footnote).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if storeManager.isPurchasing { ProgressView("Connecting to the App Store") }

            Text("Subscriptions renew automatically until canceled in your App Store account settings.")
                .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)

            Button("Restore Purchases") {
                Task {
                    await storeManager.restorePurchases()
                }
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))

            .disabled(storeManager.isPurchasing)

            Button("Not Now") {
                dismiss()
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
        }
        .padding(28)
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity)
        }
        .task {
            await storeManager.loadProducts()
            await storeManager.updateCustomerProductStatus()
        }
        .onChange(of: storeManager.hasPremium) { _, hasPremium in
            if hasPremium {
                dismiss()
            }
        }
    }

    private func billingPeriod(_ product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else { return "purchase" }
        let unit: String
        switch period.unit {
        case .day: unit = "day"
        case .week: unit = "week"
        case .month: unit = "month"
        case .year: unit = "year"
        @unknown default: unit = "period"
        }
        return period.value == 1 ? unit : "\(period.value) \(unit)s"
    }

}
