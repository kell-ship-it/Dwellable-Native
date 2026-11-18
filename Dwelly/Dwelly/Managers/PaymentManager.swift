import Foundation
import StoreKit

/// Subscription plan the user is purchasing. Product IDs are placeholders —
/// swap these for the real App Store Connect identifiers once T-254's products exist
/// (see docs/MEMORY.md Nov 2, 2026 close for the locked pricing: $7.99/mo, $59.99/yr, 14-day trial on both).
enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case monthly = "com.kellgolden.Dwell.subscription.monthly"
    case yearly = "com.kellgolden.Dwell.subscription.yearly"

    var id: String { rawValue }

    var priceDisplay: String {
        switch self {
        case .monthly: return "$7.99/month"
        case .yearly: return "$59.99/year ($5.00/month)"
        }
    }
}

enum PurchaseResult {
    case success
    case userCancelled
    case pending
    case failed(Error)
}

@MainActor
final class PaymentManager: ObservableObject {
    static let shared = PaymentManager()

    @Published private(set) var products: [SubscriptionPlan: Product] = [:]
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var hasActiveEntitlement = false
    @Published private(set) var loadError: String?
    /// Days left in an active introductory-offer (trial) period, or nil if the current
    /// entitlement (if any) isn't a trial. Drives the "Free Trial · N days left" row on
    /// Account Profile (T-224) — distinct from `hasActiveEntitlement`, which is true for
    /// both a trial and a fully paid subscription.
    @Published private(set) var trialDaysRemaining: Int?

    private var transactionListenerTask: Task<Void, Never>?

    private init() {
        transactionListenerTask = listenForTransactionUpdates()
        Task { await loadProducts() }
        // T-224: without this, hasActiveEntitlement/trialDaysRemaining stayed at their
        // initial false/nil values on a fresh launch until the next Transaction.updates
        // event fired (new purchase or renewal) — Account Profile's Subscription row
        // showed "Free" for an already-subscribed/trialing user until that happened.
        Task { await refreshEntitlementStatus() }
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    // MARK: - Product Loading

    func loadProducts() async {
        isLoadingProducts = true
        loadError = nil
        do {
            let storeProducts = try await Product.products(for: SubscriptionPlan.allCases.map(\.rawValue))
            var mapped: [SubscriptionPlan: Product] = [:]
            for product in storeProducts {
                if let plan = SubscriptionPlan(rawValue: product.id) {
                    mapped[plan] = product
                }
            }
            products = mapped
        } catch {
            loadError = error.localizedDescription
        }
        isLoadingProducts = false
    }

    // MARK: - Trial Eligibility (T-255)

    /// Whether this Apple ID has never consumed an intro offer for this subscription group.
    /// Drives the branch between the Trial Gate (first-time) and "Trial Already Used" (repeat) screens.
    func isEligibleForIntroOffer(_ plan: SubscriptionPlan) async -> Bool {
        guard let product = products[plan], let subscription = product.subscription else {
            return true // default optimistic — real products aren't loaded yet (placeholder IDs)
        }
        return await subscription.isEligibleForIntroOffer
    }

    // MARK: - Purchase

    func purchase(_ plan: SubscriptionPlan) async -> PurchaseResult {
        guard let product = products[plan] else {
            return .failed(PaymentError.productNotLoaded)
        }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlementStatus()
                return .success
            case .userCancelled:
                return .userCancelled
            case .pending:
                return .pending
            @unknown default:
                return .failed(PaymentError.unknownResult)
            }
        } catch {
            return .failed(error)
        }
    }

    // MARK: - Restore

    func restorePurchases() async -> PurchaseResult {
        do {
            try await AppStore.sync()
            await refreshEntitlementStatus()
            return hasActiveEntitlement ? .success : .failed(PaymentError.noActiveSubscription)
        } catch {
            return .failed(error)
        }
    }

    // MARK: - Entitlement Status

    func refreshEntitlementStatus() async {
        var active = false
        var daysRemaining: Int?
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result), SubscriptionPlan(rawValue: transaction.productID) != nil {
                active = true
                if transaction.offerType == .introductory, let expirationDate = transaction.expirationDate {
                    let days = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
                    daysRemaining = max(0, days)
                }
            }
        }
        hasActiveEntitlement = active
        trialDaysRemaining = daysRemaining
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self, let transaction = try? self.checkVerified(result) else { continue }
                await transaction.finish()
                await self.refreshEntitlementStatus()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PaymentError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum PaymentError: LocalizedError {
    case productNotLoaded
    case failedVerification
    case unknownResult
    case noActiveSubscription

    var errorDescription: String? {
        switch self {
        case .productNotLoaded: return "That plan isn't available right now."
        case .failedVerification: return "We couldn't verify this purchase."
        case .unknownResult: return "Something unexpected happened."
        case .noActiveSubscription: return "No active subscription found for this Apple ID."
        }
    }
}
