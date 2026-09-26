# One free activity per section

The six free activities are Letter Twins, Shape Post, Number Picnic, Habitat Helpers, Read Together (including its four books), and Funny Face Studio. Premium unlocks all other 66 activities across the six sections using the existing monthly subscription product `com.learninglabjr.premium.monthly`.

`GameAccessPolicy` owns the six stable free activity IDs. Unknown/new IDs require Premium by default. All six category menus use `PremiumActivityLink`, which shows locks and an accessible Premium label for non-subscribers, presents the existing parent gate before purchase, and allows direct navigation for subscribers. An open paid destination also observes entitlement changes and stops narration and item audio before returning to the parent gate when access is lost.

The paywall, Parents Corner, and local StoreKit product description explain the new model. The App Store Connect subscription description must also be updated; editing the local StoreKit file does not modify App Store Connect. No price or trial terms were changed.

Validation covers every current activity with and without a subscription, exactly six free and 66 paid activities, and unknown IDs defaulting to Premium. UI coverage checks first-game access and second-game locks in every category, purchase, subscribed access across all six categories, and refund while a paid game is open. Existing gameplay fixtures now acquire a test subscription unless they explicitly exercise the free experience.

Pre-existing Story Time implementation changes are preserved locally; only the access wrapper and test subscription setup from this task are included in the commit.

Validation result: 122 native tests and three UI tests passed on iOS 26.1. The UI tests verified all six free first activities, all six second-activity parent gates, paid access across every section, refund during an open paid game, and a purchase from the paywall.
