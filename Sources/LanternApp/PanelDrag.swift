import Foundation

/// Preserve the original grab offset in screen coordinates, independent of the moving window.
struct PanelDrag {
    private let initialOrigin: CGPoint
    private let initialPointer: CGPoint

    init(origin: CGPoint, pointer: CGPoint, initialTranslation: CGPoint) {
        initialOrigin = origin
        // Recognition starts after a threshold; include the movement already consumed by the pan.
        initialPointer = CGPoint(x: pointer.x - initialTranslation.x, y: pointer.y - initialTranslation.y)
    }

    func origin(at pointer: CGPoint) -> CGPoint {
        CGPoint(x: initialOrigin.x + pointer.x - initialPointer.x,
                y: initialOrigin.y + pointer.y - initialPointer.y)
    }
}
