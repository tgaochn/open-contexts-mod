import Foundation
import ServiceManagement

/// "Launch at login" via the modern ServiceManagement API (macOS 13+). Registers the main app
/// bundle itself as a login item — no separate helper target or AppleScript needed.
enum LoginItem {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// Registers/unregisters the app as a login item. Returns false (and logs) on failure.
    @discardableResult
    static func setEnabled(_ enabled: Bool) -> Bool {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
            return true
        } catch {
            NSLog("LoginItem.setEnabled(\(enabled)) failed: \(error.localizedDescription)")
            return false
        }
    }
}
