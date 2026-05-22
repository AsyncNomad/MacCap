import AVFoundation
import CoreMedia
import Darwin
import Foundation
import MacCapDomain
import ScreenCaptureKit

@MainActor
public final class ScreenCaptureRecordingController: NSObject, RecordingControlling {
    public var stateDidChange: ((RecordingLifecycleState) -> Void)?

    private let permissions = PermissionCoordinator()
    private let displayDiscovery = DisplayDiscovery()
    private let outputFactory = RecordingOutputFactory()

    private var stream: SCStream?
    private var recordingOutput: SCRecordingOutput?
    private var currentSession: RecordingSession?
    private var stoppingSession: RecordingSession?
    private var stopContinuation: CheckedContinuation<RecordingSession, Error>?

    public override init() {
        super.init()
    }

    public func availableDisplays() async throws -> [CaptureDisplay] {
        let displays = try await displayDiscovery.fetchDisplays()
        if displays.isEmpty {
            throw RecordingError.noDisplaysAvailable
        }

        return displays
    }

    public func startRecording(with configuration: RecordingConfiguration) async throws -> RecordingSession {
        guard currentSession == nil else {
            throw RecordingError.activeRecordingExists
        }

        stateDidChange?(.preparing)

        do {
            try await permissions.ensureScreenRecordingAccess()
            try await permissions.ensureMicrophoneAccessIfNeeded(includeMicrophone: configuration.includeMicrophone)

            let display = try await displayDiscovery.findDisplay(matching: configuration.display.displayID)
            let filter = try await makeContentFilter(for: display)
            let streamConfiguration = makeStreamConfiguration(for: configuration, display: display)
            let stream = SCStream(filter: filter, configuration: streamConfiguration, delegate: self)
            let (recordingOutput, outputURL) = try outputFactory.makeRecordingOutput(
                baseDirectoryURL: configuration.outputDirectoryURL,
                qualityPreset: configuration.qualityPreset,
                delegate: self
            )

            try stream.addRecordingOutput(recordingOutput)
            try await startCapture(stream)

            let session = RecordingSession(
                outputURL: outputURL,
                startedAt: Date(),
                display: configuration.display,
                includesMicrophone: configuration.includeMicrophone
            )

            self.stream = stream
            self.recordingOutput = recordingOutput
            self.currentSession = session
            stateDidChange?(.recording(session))
            return session
        } catch {
            self.stream = nil
            self.recordingOutput = nil
            self.currentSession = nil
            stateDidChange?(.failed(error.localizedDescription))
            throw error
        }
    }

    public func stopRecording() async throws -> RecordingSession {
        guard let stream, let session = currentSession else {
            throw RecordingError.noActiveRecording
        }

        stateDidChange?(.stopping(session))
        stoppingSession = session

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<RecordingSession, Error>) in
            stopContinuation = continuation

            Task { @MainActor in
                do {
                    try await self.stopCapture(stream)
                } catch {
                    self.handleRecordingFailure(error)
                }
            }
        }
    }

    private func makeStreamConfiguration(
        for configuration: RecordingConfiguration,
        display: SCDisplay
    ) -> SCStreamConfiguration {
        let streamConfiguration = SCStreamConfiguration()
        let scaleFactor = configuration.qualityPreset.usesRetinaScale ? max(configuration.display.scaleFactor, 1.0) : 1.0
        streamConfiguration.width = Int(Double(display.width) * scaleFactor)
        streamConfiguration.height = Int(Double(display.height) * scaleFactor)
        streamConfiguration.minimumFrameInterval = CMTime(value: 1, timescale: configuration.qualityPreset.frameRate)
        streamConfiguration.queueDepth = 6
        streamConfiguration.showsCursor = configuration.showsCursor
        streamConfiguration.capturesAudio = true
        streamConfiguration.excludesCurrentProcessAudio = false
        streamConfiguration.captureMicrophone = configuration.includeMicrophone
        streamConfiguration.sampleRate = 48_000
        streamConfiguration.channelCount = 2
        streamConfiguration.captureResolution = configuration.qualityPreset.captureResolution
        streamConfiguration.scalesToFit = false
        streamConfiguration.preservesAspectRatio = true
        return streamConfiguration
    }

    private func makeContentFilter(for display: SCDisplay) async throws -> SCContentFilter {
        if let currentApplication = try await displayDiscovery.findApplication(processID: getpid()) {
            return SCContentFilter(
                display: display,
                excludingApplications: [currentApplication],
                exceptingWindows: []
            )
        }

        return SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
    }

    private func startCapture(_ stream: SCStream) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            stream.startCapture { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func stopCapture(_ stream: SCStream) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            stream.stopCapture { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func handleRecordingFailure(_ error: any Error) {
        stopContinuation?.resume(throwing: error)
        stopContinuation = nil
        stoppingSession = nil
        currentSession = nil
        stream = nil
        recordingOutput = nil
        stateDidChange?(.failed(error.localizedDescription))
    }

    private func handleRecordingDidFinish() {
        guard let session = stoppingSession ?? currentSession else {
            stopContinuation = nil
            stoppingSession = nil
            currentSession = nil
            stream = nil
            recordingOutput = nil
            return
        }

        stopContinuation?.resume(returning: session)
        stopContinuation = nil
        stoppingSession = nil
        currentSession = nil
        stream = nil
        recordingOutput = nil
        stateDidChange?(.finished(session))
    }
}

extension ScreenCaptureRecordingController: SCRecordingOutputDelegate {
    nonisolated public func recordingOutputDidStartRecording(_ recordingOutput: SCRecordingOutput) {}

    nonisolated public func recordingOutputDidFinishRecording(_ recordingOutput: SCRecordingOutput) {
        Task { @MainActor in
            self.handleRecordingDidFinish()
        }
    }

    nonisolated public func recordingOutput(_ recordingOutput: SCRecordingOutput, didFailWithError error: any Error) {
        Task { @MainActor in
            self.handleRecordingFailure(error)
        }
    }
}

extension ScreenCaptureRecordingController: SCStreamDelegate {
    nonisolated public func stream(_ stream: SCStream, didStopWithError error: any Error) {
        Task { @MainActor in
            self.handleRecordingFailure(error)
        }
    }
}
