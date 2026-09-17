# Offline Polly narration

The app plays bundled MP3 recordings through its shared narrator. AWS is used only by this development tool. Families do not need AWS access or a network connection, and credentials are never embedded in the app.

## Narration and delivery

The source catalogs expand game directions, finite number/object/letter variations, feedback, and all 60 book pages. The `text` field is the exact runtime lookup key, normalized to Unicode NFC and single spaces. `spokenText` may improve spoken phrasing while preserving the instruction. Keep both fields when changing a game's displayed words.

The default narrator is Ruth, US English, with Polly's Generative engine. Delivery varies gently: playful prompts use natural delivery without rate overrides, clear directions use 95% speed, stories 94%, and gentle prompts 90%. Short labels use the voice's normal delivery. SSML controls pacing rather than asking Polly to speak performance notes. Explicit Neural SSML handles letter names and syllable pronunciation. Both engines use the same named voice, although their delivery can differ.

The voice is an original stock narrator. No named performer's recording or voice clone is used. Listen to the auditions and pronunciation-sensitive clips on a real device before release. Generated files are marked as not human reviewed; successful synthesis and decoding do not establish naturalness or teaching accuracy.

## Access

Use a signed-in local AWS profile. This project's working profile is `admin`, with generation in `us-east-1`. Renew an expired login with:

```sh
aws login --profile admin --region us-east-1
```

The existing account can already list Polly voices. The minimal permission template is [Source/polly-generation-policy.json](Source/polly-generation-policy.json): `polly:DescribeVoices` and `polly:SynthesizeSpeech` in this region. The template is provided for a dedicated development role; it has not been attached to or used to broaden any IAM identity. This workflow does not create servers, buckets, or public endpoints.

## Prepare the tool

Use an isolated environment. The CRT dependency is required by AWS's `aws login` credential provider.

```sh
python3 -m venv /private/tmp/LearningLabJr-polly-venv
/private/tmp/LearningLabJr-polly-venv/bin/python -m pip install 'boto3[crt]==1.42.96'
```

Run commands from the application source directory:

```sh
# Local planning only: no AWS requests and no synthesis charges.
/private/tmp/LearningLabJr-polly-venv/bin/python Narration/generate_polly.py plan

# Nine samples: Joanna, Ruth, and Salli reading three short scripts.
/private/tmp/LearningLabJr-polly-venv/bin/python Narration/generate_polly.py audition --max-usd 0.20

# Generate the library, keeping the two ledgers' combined cap at $10.
/private/tmp/LearningLabJr-polly-venv/bin/python Narration/generate_polly.py generate --max-usd 9.80

# Verify published files against their recorded hashes.
/private/tmp/LearningLabJr-polly-venv/bin/python Narration/generate_polly.py verify

# Offline generator and source-coverage checks.
PYTHONDONTWRITEBYTECODE=1 /private/tmp/LearningLabJr-polly-venv/bin/python -m unittest discover -s Narration -p 'test_*.py' -v
```

The audition player is `/private/tmp/LearningLabJr-Polly-Auditions/index.html`. Production files go to `NarrationAudio/`; Xcode includes these MP3s and `NarrationAudioManifest.json`. Keep the generated audio files with the manifest when transferring the project.

### Conversational delivery comparison

`audition_friendly.py` compares Joanna, Salli, and Ruth using revised greeting, counting, and completion scripts. It removes most rate overrides, preserves a slower counting sentence, and adds short response pauses. The HTML player includes the current app preview as a reference. These are candidate samples, not a human-reviewed improvement or a replacement for the production library.

```sh
# Plan, then generate only the nine comparison clips (separate $0.20 cap).
PYTHONDONTWRITEBYTECODE=1 /private/tmp/LearningLabJr-polly-venv/bin/python Narration/audition_friendly.py
PYTHONDONTWRITEBYTECODE=1 /private/tmp/LearningLabJr-polly-venv/bin/python Narration/audition_friendly.py --generate
```

Open `/private/tmp/LearningLabJr-Friendly-Voices/index.html` to compare. Keep the whole directory if moving the player elsewhere. Ruth was selected after this comparison. Production now uses the revised greeting and completion scripts and the conversational pacing policy; preserve explicit letter-pronunciation markup and calm delivery for feelings and bedtime activities.

## Cost control and recovery

Planning uses published character rates without assuming free-tier eligibility. Estimates exclude taxes and are not a substitute for the AWS bill. A conservative reservation counting the full SSML length is saved before transmission, including requests that fail or are interrupted. Successful requests reconcile to AWS's returned character count; older ledger estimates also honor that count when it is higher. SDK retries are disabled so no untracked automatic paid retry occurs. Generation uses at most three workers and four request starts per second.

The production spending ledger is `Source/polly-generation-ledger.json`. Auditions have a separate ledger in their temporary output directory. The cap is cumulative within each ledger, not reset by rerunning the command. Completed files with matching hashes are reused. A damaged, missing, failed, or interrupted recording requires `--retry-failed` to permit another attempt; that attempt is reserved against the cap too. Do not delete the ledger to resume a job.

The app manifest is replaced atomically only after every requested clip is available. A partial job leaves any previously published manifest unchanged. To change the narrator, use `--voice Joanna` or `--voice Salli`; this generates new files and consumes another full pass. A completed manifest uses a single selected narrator, plus the catalog's explicit Neural pronunciation overrides.

## App behavior and validation

Parents can choose the Learning Lab narrator or an installed Apple voice. Missing or unplayable recordings fall back to the installed voice. Mute, repeat, music ducking, VoiceOver, backgrounding, navigation, and session limits continue to use the shared narration controls. Rapid taps replace the current recording rather than queueing speech.

The test fixtures validate manifest lookup, all bundled files' decoding, all story-page text, and literal narration calls. UI smoke tests pass `-validateNarrationCoverage`, which makes a missing recording fail loudly in Debug during tested routes. Finite dynamic variants are curated in the catalogs and still need gameplay review. Update the catalogs whenever game prompts change.

The parent Xcode project excludes `*.py`, `*.pyc`, `narration-source-*.json`, and `polly-*` from the application bundle, alongside existing Markdown/test fixture exclusions. The project file is outside this Git root; preserve these settings when transferring the project. The tracked `polly-project-settings.patch` captures the applied settings change for that parent project. On another checkout, review it and apply from the directory containing `LearningLabJr.xcodeproj` with `git apply LearningLabJr/Narration/polly-project-settings.patch` if the settings are not already present.

References: [Polly pricing](https://aws.amazon.com/polly/pricing/), [Generative voices](https://docs.aws.amazon.com/polly/latest/dg/generative-voices.html), [SSML support](https://docs.aws.amazon.com/polly/latest/dg/supportedtags.html), [storing and replaying speech](https://aws.amazon.com/polly/faqs/).
