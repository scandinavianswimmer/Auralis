# Native Apple controls and Emil Kowalski interaction guidance

Auralis is a native SwiftUI/AppKit macOS app. Its interface is compiled against Apple's macOS 26 SDK and uses system Liquid Glass APIs where available.

## Applied changes

- The mixer uses SwiftUI `Slider` for output, microphone, and per-app levels. System hit testing, keyboard adjustment, accessibility, and pointer tracking replace the custom glass-thumb renderer and gesture math.
- Slider transactions suppress inherited animation, keeping the control directly attached to its input.
- Section navigation uses SwiftUI's segmented `Picker`. The operating system supplies selection, focus, and interaction feedback; switching content does not trigger a global layout spring.
- Mixer options use `DisclosureGroup` and a short, critically damped SwiftUI spring for mouse activation. Keyboard/assistive activation and Reduce Motion use immediate updates.
- Section labels use system semantic typography. Existing native glass footer buttons, system appearance, and Reduce Transparency behavior remain in place.

## References

- [Apple: Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/liquid-glass)
- [Apple: Modernize your AppKit app, WWDC26](https://developer.apple.com/videos/play/wwdc2026/289/)
- [Emil Kowalski: Apple Design skill](https://github.com/emilkowalski/skill/blob/main/skills/apple-design/SKILL.md)
- [Emil Kowalski: Great Animations](https://emilkowal.ski/ui/great-animations)

Emil's Apple Design skill describes principles in web terms. This implementation applies the interaction principles through Apple's native controls and SwiftUI animation APIs; it does not embed a web UI or add a JavaScript animation library.

## SDK constraint

A local SwiftUI `@State` typecheck with the default macOS 27 SDK fails because `SwiftUIMacros.StateMacro` cannot be loaded by this Command Line Tools installation. The working build uses the existing macOS 26 SDK compatibility setup. No macOS 27 runtime verification is claimed; this Mac runs macOS 26.6.2.

## Verification

Built successfully with the Apple macOS 26 SDK. App self-test and strict bundle signature verification passed. All 309 mixer checks and the 19-check limiter recovery regression passed. Live UI inspection verified native slider accessibility roles, segmented navigation, and options expansion on macOS 26.6.2.
