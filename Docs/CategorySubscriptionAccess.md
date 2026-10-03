# One free activity per section

The six free activities are Letter Twins, Shape Post, Number Picnic, Habitat Helpers, Read Together (Owen Onion Finds His Voice only), and Funny Face Studio. The three Trey Triceratops books also require Premium. Premium unlocks all other 66 activities across the six sections using the existing monthly subscription product `com.learninglabjr.premium.monthly`.

`GameAccessPolicy` owns the six stable free activity IDs and a separate free-book ID for Owen Onion. The library itself remains accessible without a subscription; each book has its own access check. Unknown/new IDs require Premium by default. All six category menus use `PremiumActivityLink`, which shows locks and an accessible Premium label for non-subscribers, presents a dismissible subscription invitation with the existing parent gate before purchase, and allows direct navigation for subscribers. An open paid destination also observes entitlement changes and stops narration and item audio before returning to the parent gate when access is lost.

The paywall, Parents Corner, and local StoreKit product description explain the new model. The App Store Connect subscription description must also be updated; editing the local StoreKit file does not modify App Store Connect. No price or trial terms were changed.

Validation covers every current activity with and without a subscription, exactly six free and 66 paid activities, and unknown IDs defaulting to Premium. UI coverage checks first-game access and second-game locks in every category, purchase, subscribed access across all six categories, and refund while a paid game is open. Existing gameplay fixtures now acquire a test subscription unless they explicitly exercise the free experience.

Pre-existing Story Time implementation changes are preserved locally; only the access wrapper and test subscription setup from this task are included in the commit.

Validation result: 122 native tests and three UI tests passed on iOS 26.1. The UI tests verified all six free first activities, all six second-activity parent gates, paid access across every section, refund during an open paid game, and a purchase from the paywall.

Read Together follow-up: seven subscription/access tests and one book-navigation UI test passed. Owen Onion remains free; all three dinosaur books require Premium. The UI test verifies all three locks, subscribed reading, refund during an open paid book, and continued free access to Owen Onion afterward.

First-tap subscription invitation: users without Premium see a dismissible invitation on their first tap each app launch. The home screen waits for the initial StoreKit entitlement check before deciding, so existing monthly and annual subscribers navigate directly. Closing the invitation continues to the selected category or Parents Corner; returning home or foregrounding does not repeat it during the same launch. Tapping a locked activity or book always offers Premium again. The invitation has a visible close button and Continue with free games; See subscription plans opens the grown-up challenge before prices, purchases, restoration, and external links.

October 3, 2026 validation: 13 subscription/access tests and five UI tests passed on the iOS 26.1 iPhone simulator. Coverage includes both subscriber plans skipping the prompt, first tap on a category or home artwork, both dismissal controls, free-game play, repeated locked-game prompts, no repeat when returning home, a new prompt after relaunch, landscape Parents Corner, and the parent-gated purchase flow. Activate the UI fixtures with LearningLabJr.storekit included in the UI-test bundle.
