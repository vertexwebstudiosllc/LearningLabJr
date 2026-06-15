import Foundation
import Combine
import StoreKit
import SwiftUI

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published var products: [Product] = []
    @Published var hasPremium: Bool = false

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
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)

                await updateCustomerProductStatus()
                await transaction.finish()

            case .userCancelled:
                print("User cancelled purchase")

            case .pending:
                print("Purchase is pending approval")

            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            print("Restore failed: \(error)")
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

                if transaction.revocationDate == nil {
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            premiumActive = true
                        }
                    } else {
                        premiumActive = true
                    }
                }
            } catch {
                print("Unverified transaction")
            }
        }

        hasPremium = premiumActive
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
    @ObservedObject private var storeManager = StoreManager.shared
    @State private var answer = ""
    @State private var showPaywall = false
    @State private var showError = false

    private let correctAnswer = "8"

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 52, weight: .bold))
                .foregroundColor(Color(red: 0.20, green: 0.55, blue: 0.95))

            Text("Parent Check")
                .font(.system(size: 30, weight: .bold, design: .rounded))

            Text("To unlock premium games, please answer:")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)

            Text("3 + 5 = ?")
                .font(.system(size: 26, weight: .bold, design: .rounded))

            TextField("Answer", text: $answer)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .frame(maxWidth: 180)

            if showError {
                Text("Please try again.")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.red)
            }

            Button {
                if answer.trimmingCharacters(in: .whitespacesAndNewlines) == correctAnswer {
                    showPaywall = true
                    showError = false
                } else {
                    showError = true
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.10, green: 0.58, blue: 0.78))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            Button("Cancel") {
                dismiss()
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
        }
        .padding(28)
        .onChange(of: storeManager.hasPremium) { hasPremium in
            if hasPremium {
                dismiss()
            }
        }
        .sheet(isPresented: $showPaywall) {
            PremiumPaywallView()
        }
    }
}

struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storeManager = StoreManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 52, weight: .bold))
                .foregroundColor(Color(red: 0.96, green: 0.62, blue: 0.18))

            Text("Unlock Premium Games")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            Text("Subscribe to unlock the premium games across Learning Lab Jr.")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let product = storeManager.products.first {
                Button {
                    Task {
                        await storeManager.purchase(product)
                    }
                } label: {
                    Text("Subscribe \(product.displayPrice)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.10, green: 0.58, blue: 0.78))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            } else {
                Text("Subscription unavailable")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)

                Button("Try Again") {
                    Task {
                        await storeManager.loadProducts()
                    }
                }
                .font(.system(size: 17, weight: .bold, design: .rounded))
            }

            Button("Restore Purchases") {
                Task {
                    await storeManager.restorePurchases()
                }
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))

            Button("Not Now") {
                dismiss()
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
        }
        .padding(28)
        .task {
            await storeManager.loadProducts()
            await storeManager.updateCustomerProductStatus()
        }
        .onChange(of: storeManager.hasPremium) { hasPremium in
            if hasPremium {
                dismiss()
            }
        }
    }
}
