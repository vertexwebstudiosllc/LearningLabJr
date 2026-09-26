# Release readiness — September 26, 2026

The release fixes in this change improve the subscription and privacy implementation. They do not certify that the production App Store subscription is configured or approved. App Store Connect was not accessible during this review.

## Changes

- Added Privacy Policy and Apple standard Terms of Use links to the parent-gated paywall and Parents Corner, plus the live app contact page in Parents Corner.
- Display the App Store product name, localized recurring price, and eligible introductory offer, including the price that follows a trial. Offer details come from StoreKit; the app does not promise a trial to ineligible subscribers.
- Refresh verified entitlements on foreground entry. Prevent older overlapping refreshes from overwriting newer entitlement results.
- Keep StoreKit's current-entitlement handling for subscribed and billing-grace-period access. Canceled auto-renewal does not remove already-paid access; expired/refunded purchases do not grant access.
- Added a clear unavailable-product message and restricted purchase requests to the expected auto-renewable product.
- Added `PrivacyInfo.xcprivacy` declaring local UserDefaults access (`CA92.1`), no tracking, and no collected app data. Parent-initiated support submissions on the external website are separately explained in the published policy.
- Updated local StoreKit product display text. The local $3.99 monthly price and one-week introductory trial are test settings only; they do not create or configure an App Store Connect subscription.

## Production configuration still to verify

1. App bundle ID is `com.learninglabjr.app`. Its auto-renewable monthly subscription must use the exact product ID `com.learninglabjr.premium.monthly` in the correct subscription group.
2. Complete the Paid Apps agreement, banking, and tax information. Confirm price, territories/availability, localized subscription name and description, and review screenshot. Configure an introductory offer only if intended.
3. Submit the first subscription together with the app version. The first activity in each section is free (six total): Letter Twins, Shape Post, Number Picnic, Habitat Helpers, Read Together, and Funny Face Studio. Premium unlocks the other 66 activities across all six sections. Update the subscription description in App Store Connect to match.
4. Upload the release archive and test an actual TestFlight installation on a device: purchase, restore after reinstall, cancel auto-renewal, expiration, refund/revocation, pending/Ask to Buy, offline relaunch with an active subscription, and billing grace period if enabled. Simulator StoreKit tests do not verify Apple's production product configuration.
5. Set the Privacy Policy URL to `https://vertexwebstudios.com/learning-lab-jr-privacy.html`; use `https://vertexwebstudios.com/learning-lab-jr.html#contact` for support. Include Apple's standard EULA link in the app description. Complete privacy and age-rating/Kids Category declarations for the shipped build.
6. Check release signing, archive validation, version/build uniqueness, real-device audio and accessibility, and iPhone/iPad layouts. The current Xcode project targets iOS/iPadOS 26.1 and later; older OS versions cannot install it.
7. Review the pre-existing uncommitted Story Time work separately before deciding what to ship. This release-fix commit does not silently include those unrelated changes or duplicate narration files.

## Validation

Five new app-hosted StoreKit tests passed on the iOS 26.1 simulator: purchase/restore/expiration, refund, canceled renewal through expiration, Ask to Buy approval, and bundled privacy manifest/links. The broader regression run passed 121 native tests and one paywall UI test, with zero failures. An unsigned Release build for generic iOS devices also succeeded; this is compilation validation, not a distribution-signed archive or App Store upload validation. The UI test verified the parent gate, eligible trial copy, legal links, restore control, and a purchase unlocking Letter Draw.

Tests run using the disposable validation project and source mirror to avoid the repository's macOS file-coordination stalls. Test fixtures remain in `Validation/` and `prepare_validation.py` includes the new subscription and paywall tests.

## Apple references

- [Configure In-App Purchases](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases)
- [TestFlight subscription testing](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testing-subscriptions-and-in-app-purchases-in-testflight)
- [Current entitlements](https://developer.apple.com/documentation/storekit/transaction/currententitlements)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Required-reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api)
