# Auralis

A personal, GPL-3.0-or-later fork of [Vorssaint](https://github.com/vorssaint/vorssaint-utils), based on commit c870d93b (3.4.0). Auralis is not an official Vorssaint or Apple product.

## Changes

- Native macOS 26+ Liquid Glass enabled by default for panels and floating surfaces; follows system appearance and Reduce Transparency.
- Removed the extra tint plate over the menu panel's native glass.
- Native glass footer buttons and an animated glass navigation selection, with Reduce Motion support and accessible selection labels.
- Calmer section typography, more breathing room, and softer card corners.
- Separate app name, generated icon, bundle/preferences identity, and disabled automatic source-build updates. Original copyright and GPL notices are retained.
- Fixed both lookahead limiter implementations retaining excessive attenuation after a strong peak when subsequent audio remains above the ceiling. Recovery maintains the lookahead hold and linked stereo gain. A 0.1% peak tolerance avoids chattering on steady sampled tones, and the attack lands exactly on its target.

## Build and use

Requires Apple Silicon, macOS 14+, and current Apple Command Line Tools. Liquid Glass requires macOS 26+. This build uses the installed macOS 26 SDK; it does not require unverified macOS 27-only APIs.

```sh
./script/build_and_run.sh --build-only
./script/test_limiter.sh
./build.sh --test-suite=mixer
```

The app is `build/stage/Auralis.app`. Quit Vorssaint before using Auralis as your mixer, then open the app. Auralis has separate preferences and will request its own permissions when a feature needs them. The build uses local ad-hoc signing, without modifying a keychain. Rebuilding may require granting permissions again. Protected fan control requires a configured signing identity and is not verified in this local build.

`./script/build_and_run.sh --verify` builds, launches, and checks the process. It leaves the bundle ready without launching if Vorssaint is still running. `--logs`, `--telemetry`, and `--debug` are also available.

## Verification and remaining observation

The new regression failed against upstream in both buffer layouts at 44.1/48/96 kHz, then passed after the fix. All 309 upstream mixer checks pass, including ceiling protection, steady-waveform preservation, buffer boundaries, and routing contracts. The full final suite passed 69,500 checks and preference cleanup. The app also passed its self-test, strict signature verification, and a live mixer-panel launch check.

This establishes a limiter defect and its correction. It does not establish that it is the only cause of the reported real-device quiet-audio symptom. Confirm by playing the same audio through the same output device with the fork; note whether any remaining issue follows wake or an output-device change.

## Upstream

The original project documentation and license remain in this repository. Source identifiers retain some upstream names for maintainability. Donations/community links in inherited pages refer to upstream; the app's source link points to this fork. No official upstream update is installed over Auralis.
