import Foundation

public struct CaptureDisplay: Identifiable, Hashable, Sendable {
    public let displayID: UInt32
    public let name: String
    public let width: Int
    public let height: Int
    public let scaleFactor: Double

    public init(displayID: UInt32, name: String, width: Int, height: Int, scaleFactor: Double) {
        self.displayID = displayID
        self.name = name
        self.width = width
        self.height = height
        self.scaleFactor = scaleFactor
    }

    public var id: UInt32 { displayID }

    public var resolutionDescription: String {
        "\(width) x \(height)"
    }
}
