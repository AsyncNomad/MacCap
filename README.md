# MacCap

MacCap is a macOS-native screen recorder focused on a simple rule set:

- System audio is always captured.
- Microphone audio is captured only when the user enables it.
- The first production path favors full-display capture for better compatibility with Zoom playback and meeting audio.

## Tech stack

- Swift
- SwiftUI
- ScreenCaptureKit
- AVFoundation

## Current project shape

- `Sources/MacCapApp`: app entry point
- `Sources/MacCapFeatureRecording`: recording UI and presentation logic
- `Sources/MacCapDomain`: pure domain types
- `Sources/MacCapInfrastructureCapture`: ScreenCaptureKit integration
- `Docs/architecture.md`: structure and principles

## Notes

- The package currently targets `macOS 15` because it uses `SCRecordingOutput` for clean file-based recording.
- For shipping, add privacy descriptions for screen capture and microphone use in an Xcode app target.
- The intended default test scenario is Zoom meeting playback on the selected display with system audio enabled.
