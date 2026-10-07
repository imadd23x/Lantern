import Foundation

/// One top-center anchor for both presentations. Display constraints also apply to remembered positions.
enum PanelPlacement {
    static let compact = CGSize(width: 288, height: 46)
    static let expanded = CGSize(width: 460, height: 584)

    static func revealHotspot(for compactFrame: CGRect) -> CGRect {
        CGRect(x: compactFrame.minX, y: compactFrame.maxY - 8, width: compactFrame.width, height: 12)
    }

    static func frame(size: CGSize, anchor: CGPoint, bounds: CGRect) -> CGRect {
        let available = bounds.insetBy(dx: 8, dy: 8)
        let size = CGSize(width: min(size.width, available.width), height: min(size.height, available.height))
        let x = anchor.x.isFinite ? anchor.x : available.midX
        let top = anchor.y.isFinite ? anchor.y : available.maxY
        return CGRect(x: min(max(x - size.width / 2, available.minX), available.maxX - size.width),
                      y: min(max(top - size.height, available.minY), available.maxY - size.height),
                      width: size.width, height: size.height)
    }
}

struct PointerEntry {
    private var inside: Bool
    init(inside: Bool) { self.inside = inside }
    mutating func entered(isInside: Bool) -> Bool {
        defer { inside = isInside }
        return isInside && !inside
    }
}

/// A window relayout cannot restart or bypass the independently timed details reveal.
struct PanelRevealReadiness {
    private var expanded = false
    private var deadline: TimeInterval = 0
    mutating func update(expanded next: Bool, reduced: Bool, now: TimeInterval) {
        if next && !expanded { deadline = now + (reduced ? 0 : LanternMotion.detailsSettlingInterval) }
        if !next { deadline = now }
        expanded = next
    }
    func remaining(at now: TimeInterval) -> TimeInterval { max(0, deadline - now) }
}

extension LanternMotion {
    static let detailsRevealDelay: TimeInterval = 0.12
    static let detailsRevealDuration: TimeInterval = 0.24
    static let detailsSettlingInterval: TimeInterval = detailsRevealDelay + detailsRevealDuration + 0.04
}
