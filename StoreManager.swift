import Foundation
import Combine
import StoreKit
import SwiftUI

enum AppLinks {
    static let privacy = URL(string: "https://vertexwebstudios.com/learning-lab-jr-privacy.html")!
    static let terms = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let support = URL(string: "https://vertexwebstudios.com/learning-lab-jr.html#contact")!
}

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var hasPremium: Bool = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var statusMessage: String?

    private let productIDs = PremiumPlan.productIDs

    private var entitlementRefresh = 0
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
            products = try await Product.products(for: productIDs).sorted {
                PremiumPlan.sortOrder($0.id) < PremiumPlan.sortOrder($1.id)
            }
            statusMessage = products.isEmpty ? "Premium is not available in the App Store right now. Please try again later." : nil
        } catch {
            statusMessage = "We couldn't reach the App Store. Please try again when connected."
        }
    }

    func purchase(_ product: Product) async {
        guard !isPurchasing, productIDs.contains(product.id), product.type == .autoRenewable else { return }
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
        entitlementRefresh += 1
        let refresh = entitlementRefresh
        var premiumActive = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                guard productIDs.contains(transaction.productID) else {
                    continue
                }

                // StoreKit includes subscriptions in billing grace period here.
                // A past transaction expiration date must not revoke that access.
                if transaction.revocationDate == nil && !transaction.isUpgraded { premiumActive = true }
            } catch {
                print("Unverified transaction")
            }
        }

        guard refresh == entitlementRefresh else { return }
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

enum PremiumPlan {
    static let monthlyID = "com.learninglabjr.premium.monthly"
    static let annualID = "com.learninglabjr.premium.annual"
    static let productIDs: Set<String> = [monthlyID, annualID]

    static func sortOrder(_ id: String) -> Int { id == annualID ? 0 : 1 }

    static func savingsPercent(monthly: Decimal, annual: Decimal) -> Int? {
        guard monthly > 0, annual > 0, annual < monthly * 12 else { return nil }
        var percentage = (monthly * 12 - annual) * 100 / (monthly * 12)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &percentage, 0, .down)
        return NSDecimalNumber(decimal: rounded).intValue
    }
}

struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var storeManager = StoreManager.shared
    @State private var selectedProductID = PremiumPlan.annualID
    @State private var introductoryOfferText: String?

    private let ink = Color(red: 0.08, green: 0.24, blue: 0.28)
    private let teal = Color(red: 0.04, green: 0.40, blue: 0.43)
    private let cream = Color(red: 0.98, green: 0.97, blue: 0.93)

    private var selectedProduct: Product? {
        storeManager.products.first { $0.id == selectedProductID } ?? storeManager.products.first
    }

    private var annualSavings: Int? {
        guard let monthly = storeManager.products.first(where: { $0.id == PremiumPlan.monthlyID }),
              let annual = storeManager.products.first(where: { $0.id == PremiumPlan.annualID }),
              monthly.priceFormatStyle.currencyCode == annual.priceFormatStyle.currencyCode,
              monthly.subscription?.subscriptionPeriod.unit == .month,
              annual.subscription?.subscriptionPeriod.unit == .year else { return nil }
        return PremiumPlan.savingsPercent(monthly: monthly.price, annual: annual.price)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(teal)
                        .frame(width: 76, height: 76)
                        .background(.white, in: RoundedRectangle(cornerRadius: 24))
                        .accessibilityHidden(true)
                    Text("A little play.\nA world of discovery.")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Learning Lab Jr Premium")
                        .font(.headline).foregroundStyle(teal)
                    Text("More ways to learn, imagine, and grow together.")
                        .font(.subheadline).foregroundStyle(ink.opacity(0.8))
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 12) {
                    benefit("square.grid.2x2.fill", "Every game and Read Together book")
                    benefit("wifi.slash", "Play offline, wherever you go")
                    benefit("sparkles", "New content added each month")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))

                VStack(spacing: 12) {
                    Text("Choose your plan")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(ink)
                    Text("Same Premium access. Two ways to pay.")
                        .font(.subheadline).foregroundStyle(ink.opacity(0.75))
                    ForEach(storeManager.products, id: \.id) { product in
                        planCard(product)
                    }
                    if storeManager.products.isEmpty {
                        Text(storeManager.isLoadingProducts ? "Loading plans…" : "Plans are temporarily unavailable.")
                            .foregroundStyle(ink)
                        Button("Try Again") { Task { await storeManager.loadProducts() } }
                            .disabled(storeManager.isLoadingProducts)
                    }
                }

                if let product = selectedProduct {
                    VStack(spacing: 10) {
                        if let introductoryOfferText {
                            Text(introductoryOfferText)
                                .font(.footnote).foregroundStyle(ink)
                                .multilineTextAlignment(.center)
                                .accessibilityIdentifier("premium.offer")
                        }
                        Button {
                            Task { await storeManager.purchase(product) }
                        } label: {
                            Text("Subscribe · \(product.displayPrice) / \(billingPeriod(product))")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, minHeight: 28)
                                .padding(.vertical, 14).padding(.horizontal, 12)
                                .foregroundStyle(.white)
                                .background(teal, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .disabled(storeManager.isPurchasing)
                        .opacity(storeManager.isPurchasing ? 0.65 : 1)
                        .accessibilityIdentifier("premium.subscribe")
                        Text("Renews at \(product.displayPrice) per \(billingPeriod(product)). Cancel anytime in your App Store settings.")
                            .font(.footnote).foregroundStyle(ink.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("premium.renewal")
                    }
                    .task(id: product.id) { await updateIntroductoryOffer(for: product) }
                }

                if storeManager.isPurchasing { ProgressView("Connecting to the App Store").tint(teal) }
                if let message = storeManager.statusMessage {
                    Text(message).font(.footnote).foregroundStyle(ink)
                        .multilineTextAlignment(.center)
                }
                Button("Restore Purchases") { Task { await storeManager.restorePurchases() } }
                    .font(.subheadline.weight(.semibold))
                    .disabled(storeManager.isPurchasing)
                Text("Payment is charged to your Apple Account at confirmation. Subscriptions renew automatically unless canceled at least 24 hours before the current period ends. Yearly plans are billed in one annual payment. Manage or cancel in your App Store account settings.")
                    .font(.caption).foregroundStyle(ink.opacity(0.75))
                    .multilineTextAlignment(.center)
                HStack(spacing: 24) {
                    Link("Privacy Policy", destination: AppLinks.privacy)
                    Link("Terms of Use", destination: AppLinks.terms)
                }
                .font(.footnote).frame(minHeight: 44)
                Button("Not Now") { dismiss() }
                    .font(.subheadline.weight(.semibold))
                    .disabled(storeManager.isPurchasing)
                Text("Your free games and first Read Together book are always here.")
                    .font(.caption).foregroundStyle(ink.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .background(cream.ignoresSafeArea())
        .tint(teal)
        .task {
            await storeManager.loadProducts()
            await storeManager.updateCustomerProductStatus()
        }
        .onChange(of: storeManager.hasPremium) { _, hasPremium in
            if hasPremium { dismiss() }
        }
    }

    private func benefit(_ symbol: String, _ text: String) -> some View {
        Label {
            Text(text).font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(ink)
        } icon: {
            Image(systemName: symbol).foregroundStyle(teal).frame(width: 24)
        }
    }

    private func planCard(_ product: Product) -> some View {
        let annual = product.id == PremiumPlan.annualID
        let selected = product.id == selectedProduct?.id
        return Button {
            introductoryOfferText = nil
            selectedProductID = product.id
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title2).foregroundStyle(selected ? teal : ink.opacity(0.4))
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(annual ? "Yearly" : "Monthly")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                        Spacer(minLength: 4)
                        if annual, let savings = annualSavings, savings > 0 {
                            Text("SAVE \(savings)%")
                                .font(.caption.weight(.bold)).foregroundStyle(teal)
                                .padding(.horizontal, 9).padding(.vertical, 5)
                                .background(teal.opacity(0.10), in: Capsule())
                                .accessibilityIdentifier("premium.savings")
                        }
                    }
                    Text("\(product.displayPrice) / \(billingPeriod(product))")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(annual ? "Billed yearly · about \((product.price / 12).formatted(product.priceFormatStyle))/month" : "Billed monthly · no annual commitment")
                        .font(.footnote).foregroundStyle(ink.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                    if annual, annualSavings != nil {
                        Text("Savings compared with 12 monthly payments.")
                            .font(.caption).foregroundStyle(ink.opacity(0.7))
                    }
                }
            }
            .foregroundStyle(ink)
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
            .background(selected ? Color.white : Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(selected ? teal : ink.opacity(0.15), lineWidth: selected ? 2.5 : 1))
        }
        .buttonStyle(.plain)
        .disabled(storeManager.isPurchasing)
        .accessibilityIdentifier(annual ? "premium.plan.annual" : "premium.plan.monthly")
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityValue(selected ? "Selected" : "Not selected")
    }

    private func updateIntroductoryOffer(for product: Product) async {
        introductoryOfferText = nil
        guard let subscription = product.subscription,
              let offer = subscription.introductoryOffer,
              await subscription.isEligibleForIntroOffer else { return }
        guard !Task.isCancelled, selectedProduct?.id == product.id else { return }
        let duration = periodDescription(offer.period, count: offer.periodCount)
        let renewal = "Then \(product.displayPrice) per \(billingPeriod(product)), renewing automatically."
        switch offer.paymentMode {
        case .freeTrial:
            introductoryOfferText = "\(duration) free for eligible new subscribers. \(renewal)"
        case .payUpFront:
            introductoryOfferText = "\(offer.displayPrice) for \(duration) for eligible new subscribers. \(renewal)"
        case .payAsYouGo:
            introductoryOfferText = "\(offer.displayPrice) per \(periodDescription(offer.period)) for \(duration) for eligible new subscribers. \(renewal)"
        default: break
        }
    }

    private func periodDescription(_ period: Product.SubscriptionPeriod, count: Int = 1) -> String {
        let value = period.value * count
        let unit: String
        switch period.unit {
        case .day: unit = "day"
        case .week: unit = "week"
        case .month: unit = "month"
        case .year: unit = "year"
        @unknown default: unit = "period"
        }
        return "\(value) \(unit)\(value == 1 ? "" : "s")"
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
