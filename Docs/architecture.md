# MacCap Architecture

## Product goal

`MacCap` is a macOS-native screen recorder built around a single operational rule:

- Record the selected display.
- Always capture system audio.
- Only capture microphone input when the user explicitly enables it.
- Favor full-display capture to maximize compatibility with Zoom and similar conferencing apps.

## Module boundaries

- `MacCapApp`
  - Application entry point.
  - Owns scene setup only.
- `MacCapFeatureRecording`
  - SwiftUI presentation layer.
  - Recording view model, UI state, and user-facing services.
  - AppKit workspace interactions and notification delivery are isolated behind feature-local protocols.
- `MacCapDomain`
  - Pure application models and errors.
  - No dependency on Apple capture frameworks.
- `MacCapInfrastructureCapture`
  - ScreenCaptureKit integration.
  - Permission checks, display discovery, output path generation, and stream lifecycle management.

## Design principles

- Keep UI and capture framework code separated so the recording workflow can grow without contaminating the view layer.
- Keep `ViewModel` focused on orchestration; move OS-facing behaviors such as Finder interaction, open panels, and notifications into dedicated services.
- Treat microphone capture as optional configuration, never as the default path.
- Default to display-level capture because it is the most robust baseline for Zoom playback and meeting audio scenarios.
- Keep file output creation centralized so format, naming, and storage policy can evolve in one place.

## Known follow-up work

- Add entitlements, privacy strings, and a distributable Xcode project setup for notarized releases.
- Add automated smoke tests around output URL generation and state transitions.
- Add richer telemetry, log persistence, and recovery UX for permission denial and device changes.
- Validate Zoom scenarios across speaker changes, AirPods, HDMI displays, and external microphones.
