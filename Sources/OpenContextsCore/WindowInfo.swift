import Foundation

public struct WindowInfo: Identifiable, Equatable {
    public let id: String
    public let appID: String
    public let appName: String
    public var title: String
    public var documentURL: String?
    public let processID: Int32
    /// System window number (CGWindowID): stable across app restart & sleep; 0 if unavailable.
    public let cgWindowID: UInt32

    public var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? appName : trimmed
    }

    public init(id: String, appID: String, appName: String, title: String,
                documentURL: String? = nil, processID: Int32, cgWindowID: UInt32 = 0) {
        self.id = id
        self.appID = appID
        self.appName = appName
        self.title = title
        self.documentURL = documentURL
        self.processID = processID
        self.cgWindowID = cgWindowID
    }
}
