import Foundation
import Testing
@testable import LanternApp

@Test func stationaryPointerDoesNotOscillateAsTheWindowMoves() {
    var windowOrigin = CGPoint(x: 100, y: 200)
    let pointer = CGPoint(x: 160, y: 225)
    let drag = PanelDrag(origin: windowOrigin, pointer: pointer,
                         initialTranslation: CGPoint(x: 10, y: 5))
    for _ in 0..<8 {
        // AppKit reports a new local location after moving the window under the same screen point.
        let local = CGPoint(x: pointer.x - windowOrigin.x, y: pointer.y - windowOrigin.y)
        let screen = CGPoint(x: windowOrigin.x + local.x, y: windowOrigin.y + local.y)
        windowOrigin = drag.origin(at: screen)
        #expect(windowOrigin == CGPoint(x: 110, y: 205))
    }
}

@Test func reversedDragPreservesGrabOffsetAcrossNegativeScreenCoordinates() {
    let drag = PanelDrag(origin: CGPoint(x: -900, y: -100), pointer: CGPoint(x: -810, y: -70),
                         initialTranslation: CGPoint(x: 10, y: 10))
    let grabOffset = CGPoint(x: 80, y: 20)
    for pointer in [CGPoint(x: -810, y: -70), CGPoint(x: -600, y: 100),
                    CGPoint(x: -1000, y: -200), CGPoint(x: -820, y: -80)] {
        let origin = drag.origin(at: pointer)
        #expect(CGPoint(x: pointer.x - origin.x, y: pointer.y - origin.y) == grabOffset)
    }
    #expect(drag.origin(at: CGPoint(x: -820, y: -80)) == CGPoint(x: -900, y: -100))
}
