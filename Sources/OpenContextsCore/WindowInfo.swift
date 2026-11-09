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
    /// User-set alias, display-only. Stamped from the window's saved record by GroupStore; never set
    /// by WindowService. Does NOT affect rule matching or identity keys (those use the raw `title`).
    public var alias: String?
    /// Optional hex colors ("#RRGGBB") for the "[alias]" badge; nil = default. Display-only.
    public var aliasTextColor: String?
    public var aliasBgColor: String?

    public var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.isEmpty ? appName : trimmed
        if let alias, !alias.isEmpty { return "[\(alias)] \(base)" }
        return base
    }

    public init(id: String, appID: String, appName: String, title: String,
                documentURL: String? = nil, processID: Int32, cgWindowID: UInt32 = 0,
                alias: String? = nil, aliasTextColor: String? = nil, aliasBgColor: String? = nil) {
        self.id = id
        self.appID = appID
        self.appName = appName
        self.title = title
        self.documentURL = documentURL
        self.processID = processID
        self.cgWindowID = cgWindowID
        self.alias = alias
        self.aliasTextColor = aliasTextColor
        self.aliasBgColor = aliasBgColor
    }
}
