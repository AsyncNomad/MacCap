# Apple Silicon QA Checklist

## Scope

This checklist is for `MacCap` releases that officially target Apple Silicon Macs only.

Supported hardware family:

- MacBook Air with Apple Silicon
- MacBook Pro with Apple Silicon

Recommended minimum device matrix:

- MacBook Air 13-inch
- MacBook Air 15-inch
- MacBook Pro 14-inch or 16-inch

Recommended minimum OS matrix:

- Latest macOS release in active support
- One immediately previous supported macOS release

## Release gate

`MacCap` should not be considered release-ready until every item below is verified on at least one Air model and one Pro model.

## Core recording

- App launches normally via the intended distribution method.
- Main recording button starts recording without UI glitches.
- Main recording button stops recording without hangs.
- Output file is created successfully in the selected folder.
- Recent recording can be revealed in Finder.
- The app remains responsive during recording.

## Permissions

- First-run screen recording permission flow is understandable.
- First-run microphone permission flow is understandable.
- App recovers cleanly after permission is denied and later re-enabled.
- Relaunch after permission changes works as expected.

## Display capture

- Built-in display recording works on MacBook Air 13-inch.
- Built-in display recording works on MacBook Air 15-inch.
- Built-in display recording works on MacBook Pro.
- Display picker reflects the correct built-in display.
- External display appears correctly when connected.
- Recording the external display saves the correct screen content.
- Disconnecting an external display during idle state does not break the app.
- Disconnecting an external display after it was selected is handled cleanly.

## Quality presets

For each preset below, validate both visible quality and file size trend:

- `저화질 저용량`
- `중간 화질 기본값`
- `원본 화질 대용량`

For each preset, verify:

- The UI shows the expected resolution, frame rate, codec, and storage profile.
- Recording starts successfully.
- Recording stops successfully.
- Saved file opens in QuickTime Player.
- Text remains readable at expected quality level.
- File size trend matches expectation: compact < balanced < original.

## Audio capture

- System audio records correctly with microphone disabled.
- System audio records correctly while Zoom meeting audio is playing.
- Microphone records correctly when enabled.
- Microphone is excluded when disabled.
- Headphone output does not break system audio recording.
- Bluetooth audio output does not break system audio recording.
- USB microphone input does not break recording when microphone mode is enabled.

## Zoom scenarios

- Zoom meeting gallery/speaker view is visible in the recording.
- Zoom participant audio is captured in the recording.
- Zoom screen share playback audio is captured when present.
- Turning microphone capture on adds local voice to the recording.
- Turning microphone capture off stores only system audio.
- Zoom recorded on built-in display behaves correctly on both Air and Pro models.

## Visual polish

- Floating recording status panel appears in the top-right area without covering critical system UI.
- Floating recording status panel does not appear inside the captured video.
- MacCap main window does not appear inside the captured video.
- Settings sheet layout looks correct on smaller and larger Apple Silicon laptop displays.
- Text does not clip in Korean UI.
- Toolbar icons remain aligned and crisp at different display scales.

## Stability

- Repeated start/stop cycles work for at least 10 recordings in one app session.
- Changing quality preset repeatedly does not crash the app.
- Changing save folder repeatedly does not crash the app.
- Opening settings during idle state is stable.
- Closing settings with keyboard shortcut is stable.
- App does not crash when notifications are unavailable in `swift run` style development launch.

## File validation

- Saved file extension matches the selected encoder/container path.
- Saved file plays in QuickTime Player.
- Saved file plays in VLC or another secondary player.
- Saved file can be imported into a common editor such as Final Cut Pro or Premiere Pro.

## Failure handling

- Permission denial surfaces a readable error.
- Missing display surfaces a readable error.
- Invalid save directory surfaces a readable error.
- Notification failure does not crash the app.

## Sign-off template

Before release, record:

- macOS version tested
- Device model tested
- Built-in display scale mode
- External display configuration
- Audio output device used
- Microphone device used
- Zoom version used
- Result for each quality preset
- Open issues and severity
