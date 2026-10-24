import CoreGraphics
import Foundation

public struct SidebarHoverState: Equatable {
    public private(set) var isExpanded: Bool
    private var outsideSince: TimeInterval?

    public init(isExpanded: Bool = false) {
        self.isExpanded = isExpanded
    }

    /// Forces the expanded state (used when a shortcut reveals the sidebar and the pointer
    /// then enters it, handing control back to normal hover collapse).
    public mutating func reveal() {
        isExpanded = true
        outsideSince = nil
    }

    @discardableResult
    public mutating func update(pointer: CGPoint, edgeFrame: CGRect, expandedFrame: CGRect,
                                dragging: Bool, menuOpen: Bool = false, now: TimeInterval,
                                collapseDelay: TimeInterval = 0.12) -> Bool {
        let previous = isExpanded
        if dragging || menuOpen {
            isExpanded = true
            outsideSince = nil
        } else if !isExpanded {
            if edgeFrame.contains(pointer) { isExpanded = true }
            outsideSince = nil
        } else if expandedFrame.contains(pointer) || edgeFrame.contains(pointer) {
            outsideSince = nil
        } else if let outsideSince, now >= outsideSince {
            if now - outsideSince >= max(collapseDelay, 0) {
                isExpanded = false
                self.outsideSince = nil
            }
        } else {
            outsideSince = now
        }
        return previous != isExpanded
    }
}
