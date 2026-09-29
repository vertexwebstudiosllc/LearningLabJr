# Premium plans

Both auto-renewing products grant the same Premium entitlement:

| Plan | Product ID | U.S. price | Duration |
| --- | --- | --- | --- |
| Monthly | com.learninglabjr.premium.monthly | $3.99 | One month |
| Yearly | com.learninglabjr.premium.annual | $29.99 | One year, billed upfront |

Both belong to App Store Connect subscription group 22141493, level 1. Monthly product record: 6777832289. Annual product record: 6817144910. Matching access levels allow Apple to manage plan changes within one subscription group. There are no introductory offers configured.

The paywall uses StoreKit's localized prices, clearly displays the full billed amount, and defaults to Yearly when available. A missing plan does not prevent purchasing the other available plan. Savings are calculated only when both prices use the same currency, rounded down to avoid overstating the discount, and compared with twelve monthly payments. U.S. savings are $17.89 (37%). The approximate monthly equivalent is secondary to the yearly billed amount.

The parent gate, Restore Purchases, legal links, and free activity/book access remain in place. Either verified product grants Premium; revoked and superseded transactions do not. Subscription status is refreshed on launch, foreground entry, purchase, restoration, and transaction updates.

Local testing: use LearningLabJr.storekit with the Xcode scheme. Validation/ReleaseSubscriptionTests.swift.txt covers both products, shared group, pricing, annual purchase/restore/expiration/refund, monthly lifecycle, and pending approvals. Validation/ReleasePaywallUITests.swift.txt checks the parent gate, plan selection, price disclosures, and an annual purchase. Run StoreKit tests serially with StoreKit Testing enabled.

First subscription approval still requires submission with the app version in App Store Connect. Creating products or uploading a build does not publish them. TestFlight availability remains dependent on Apple's beta-contract repair.
