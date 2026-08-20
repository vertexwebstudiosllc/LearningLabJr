# Friendly narration

The narrator uses warm, clear English, a relaxed conversational pace, and gentle encouragement. It is an original early-learning delivery; no recording or voice model of a named performer is used.

In **Parents Corner → A friendly learning voice**, parents can hear a sample and select an available Apple English voice. Automatic selection favors Premium, then Enhanced, then Standard quality. Within a quality tier it favors US English, then a female voice. A parent's explicit choice takes priority. If that voice becomes unavailable, selection falls back to another suitable voice. Novelty, Personal Voice, non-English, and third-party provider voices are excluded.

The app discovers voices available on the device using Apple's speech APIs. Enhanced and Premium voices require a download through the device's Accessibility speech settings; the app does not download them automatically. A device with only Standard voices will still sound less natural. Once a system voice is installed, the app can use it offline. [Apple: available voices](https://developer.apple.com/documentation/avfaudio/avspeechsynthesisvoice/speechvoices()), [Apple: speech quality tiers](https://developer.apple.com/documentation/avfaudio/avspeechsynthesisvoicequality).

All 72 activity routes use the shared narrator, including the storybook reader. Directions can be repeated. Rapid taps replace pending speech instead of queuing it. Game narration respects the spoken-directions preference and VoiceOver. Backgrounding the app or ending a timed session stops narration. Music lowers during speech; completion and cancellation callbacks cannot accidentally finish a newer utterance.

The parent preview is an explicit action and works while spoken game directions are off. It does not enable that preference. Preview stops when leaving the controls, backgrounding the app, changing the selected voice, or activating VoiceOver.

Validation covers ranking, a saved selection, missing-voice fallback, unsuitable voices, deterministic ordering, and the parent preview's mute behavior. Listening on a real iPhone or iPad is still needed to judge each installed voice's pronunciation and naturalness, especially individual letter names and phonics prompts. A built-in system voice cannot provide the consistency and expressive range of a professionally directed recording session.
