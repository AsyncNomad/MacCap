import Foundation
import MacCapDomain

public protocol RecordingPreferencesStoring {
    func load() -> RecordingPreferences
    func save(_ preferences: RecordingPreferences)
    func defaultOutputDirectoryURL() -> URL
}

public final class UserDefaultsRecordingPreferencesStore: RecordingPreferencesStoring {
    private enum Keys {
        static let selectedDisplayID = "selectedDisplayID"
        static let includeMicrophone = "includeMicrophone"
        static let outputDirectoryPath = "outputDirectoryPath"
        static let qualityPreset = "qualityPreset"
        static let qualityPresetSchemaVersion = "qualityPresetSchemaVersion"
    }

    private enum Schema {
        static let currentQualityPresetVersion = 2
    }

    private let userDefaults: UserDefaults
    private let fileManager: FileManager

    public init(userDefaults: UserDefaults = .standard, fileManager: FileManager = .default) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager
    }

    public func load() -> RecordingPreferences {
        let outputDirectoryURL: URL
        if let path = userDefaults.string(forKey: Keys.outputDirectoryPath), !path.isEmpty {
            outputDirectoryURL = URL(fileURLWithPath: path, isDirectory: true)
        } else {
            outputDirectoryURL = defaultOutputDirectoryURL()
        }

        let selectedDisplayID = userDefaults.object(forKey: Keys.selectedDisplayID) as? UInt32
        let includeMicrophone = userDefaults.bool(forKey: Keys.includeMicrophone)
        let savedQualityPreset = RecordingQualityPreset(
            rawValue: userDefaults.string(forKey: Keys.qualityPreset) ?? ""
        )
        let storedSchemaVersion = userDefaults.integer(forKey: Keys.qualityPresetSchemaVersion)
        let qualityPreset: RecordingQualityPreset

        if storedSchemaVersion < Schema.currentQualityPresetVersion {
            qualityPreset = migrateLegacyQualityPreset(savedQualityPreset)
        } else {
            qualityPreset = savedQualityPreset ?? .compact
        }

        return RecordingPreferences(
            selectedDisplayID: selectedDisplayID,
            includeMicrophone: includeMicrophone,
            outputDirectoryURL: outputDirectoryURL,
            qualityPreset: qualityPreset
        )
    }

    public func save(_ preferences: RecordingPreferences) {
        if let selectedDisplayID = preferences.selectedDisplayID {
            userDefaults.set(selectedDisplayID, forKey: Keys.selectedDisplayID)
        } else {
            userDefaults.removeObject(forKey: Keys.selectedDisplayID)
        }

        userDefaults.set(preferences.includeMicrophone, forKey: Keys.includeMicrophone)
        userDefaults.set(preferences.outputDirectoryURL.path, forKey: Keys.outputDirectoryPath)
        userDefaults.set(preferences.qualityPreset.rawValue, forKey: Keys.qualityPreset)
        userDefaults.set(Schema.currentQualityPresetVersion, forKey: Keys.qualityPresetSchemaVersion)
    }

    public func defaultOutputDirectoryURL() -> URL {
        let moviesDirectory = fileManager.urls(for: .moviesDirectory, in: .userDomainMask).first
        return (moviesDirectory ?? fileManager.homeDirectoryForCurrentUser)
            .appendingPathComponent("MacCap", isDirectory: true)
    }

    private func migrateLegacyQualityPreset(_ preset: RecordingQualityPreset?) -> RecordingQualityPreset {
        switch preset {
        case .balanced:
            return .compact
        case .original:
            return .original
        case .compact:
            return .compact
        case nil:
            return .compact
        }
    }
}
