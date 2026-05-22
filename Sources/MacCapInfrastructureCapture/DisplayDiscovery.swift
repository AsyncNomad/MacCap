import AppKit
import Foundation
import MacCapDomain
import ScreenCaptureKit

struct DisplayDiscovery {
    func fetchDisplays() async throws -> [CaptureDisplay] {
        let shareableContent = try await shareableContent()

        let screenNames: [UInt32: String] = Dictionary(uniqueKeysWithValues: NSScreen.screens.compactMap { screen in
            guard
                let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
            else {
                return nil
            }

            return (screenNumber.uint32Value, screen.localizedName)
        })

        let screenScalePairs = NSScreen.screens.reduce(into: [(UInt32, Double)]()) { result, screen in
            guard
                let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
            else {
                return
            }

            result.append((screenNumber.uint32Value, screen.backingScaleFactor))
        }
        let screenScaleFactors: [UInt32: Double] = Dictionary(uniqueKeysWithValues: screenScalePairs)

        let mainDisplayID = (NSScreen.main?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?
            .uint32Value

        return shareableContent.displays
            .map { display in
                CaptureDisplay(
                    displayID: display.displayID,
                    name: screenNames[display.displayID] ?? "Display \(display.displayID)",
                    width: display.width,
                    height: display.height,
                    scaleFactor: screenScaleFactors[display.displayID] ?? 1.0
                )
            }
            .sorted { lhs, rhs in
                if lhs.displayID == mainDisplayID {
                    return true
                }

                if rhs.displayID == mainDisplayID {
                    return false
                }

                return lhs.name < rhs.name
            }
    }

    func findDisplay(matching displayID: UInt32) async throws -> SCDisplay {
        let shareableContent = try await shareableContent()

        guard let display = shareableContent.displays.first(where: { $0.displayID == displayID }) else {
            throw RecordingError.displayUnavailable
        }

        return display
    }

    func findApplication(processID: pid_t) async throws -> SCRunningApplication? {
        let shareableContent = try await shareableContent()
        return shareableContent.applications.first(where: { $0.processID == processID })
    }

    private func shareableContent() async throws -> SCShareableContent {
        try await SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )
    }
}
