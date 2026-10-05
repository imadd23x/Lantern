import Foundation

/// One top-center anchor for both presentations. Display constraints also apply to remembered positions.
enum PanelPlacement {
    static let compact = CGSize(width: 288, height: 46)
    static let expanded = CGSize(width: 460, height: 584)

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
