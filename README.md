# MacCap

MacCap is a macOS-native screen recorder designed for one specific pain point: on Mac, it is often harder than it should be to record a screen together with the sound that is actually being played.

In real workflows such as Zoom lectures, online meetings, product demos, interview practice, remote onboarding, and tutorial capture, users usually want a recorder that behaves predictably:

- the selected screen should be recorded
- system audio should be included by default
- microphone input should only be included when the user explicitly wants it

MacCap exists to remove that friction. Instead of exposing a complicated recording setup, it provides a simple recording flow optimized for practical macOS use cases, especially cases where Zoom playback and meeting audio need to be captured reliably.

## What Problem It Solves

Many screen recorders either:

- capture video but miss system audio
- mix microphone behavior into the default path
- make it unclear what quality level or output result the user will get
- behave inconsistently in Zoom-style playback scenarios

MacCap is built to make those choices explicit and stable.

## Product Principles

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
