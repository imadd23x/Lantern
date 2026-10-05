import Foundation
import AppKit
import Testing
@testable import LanternApp

@Test func gazeIsNeutralAtEyeCenter() {
    let center = CGPoint(x: 39, y: 51)
    #expect(EyeGaze.offset(pointer: center, center: center, travel: CGSize(width: 3.2, height: 2.1)) == .zero)
}

@Test func gazeFollowsDirectionAndNearDistance() {
    let result = EyeGaze.offset(pointer: CGPoint(x: 42, y: 48), center: CGPoint(x: 39, y: 51),
                                travel: CGSize(width: 3.2, height: 2.1))
    #expect(abs(result.width - 1) < 0.00001)
    #expect(abs(result.height + 1) < 0.00001)
}

@Test func distantPointersStayInsideBothEyeOpenings() {
    let travel = CGSize(width: 3.2, height: 2.1)
    for x in [39.0, 61.0] {
        for angle in stride(from: 0.0, through: Double.pi * 2, by: 0.05) {
            let result = EyeGaze.offset(pointer: CGPoint(x: x + cos(angle) * 100_000, y: 51 + sin(angle) * 100_000),
                                        center: CGPoint(x: x, y: 51), travel: travel)
            #expect(hypot(result.width / travel.width, result.height / travel.height) <= 1.000001)
            #expect(result.width.isFinite && result.height.isFinite)
        }
    }
}

@Test func invalidPointerOrTravelStaysNeutral() {
    for pointer in [CGPoint(x: Double.nan, y: 0), CGPoint(x: 0, y: Double.infinity)] {
        #expect(EyeGaze.offset(pointer: pointer, center: .zero, travel: CGSize(width: 3, height: 2)) == .zero)
    }
    #expect(EyeGaze.offset(pointer: CGPoint(x: 100, y: 100), center: .zero, travel: .zero) == .zero)
}

/// Exercise native attach/detach/dismantle without ordering a test window on the user's screen.
@MainActor
@Test func cursorSamplerBelongsToTheAttachedView() {
    _ = NSApplication.shared
    let window = VisibleTestWindow(contentRect: CGRect(x: 0, y: 0, width: 100, height: 100),
                                   styleMask: .borderless, backing: .buffered, defer: false)
    let reader = CursorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    reader.onMove = { _ in }
    #expect(!reader.isSampling)
    window.contentView = reader
    #expect(reader.isSampling)
    window.contentView = nil
    #expect(!reader.isSampling)
    window.contentView = reader
    #expect(reader.isSampling)
    CursorReader.dismantleNSView(reader, coordinator: ())
    #expect(!reader.isSampling)
    #expect(reader.onMove == nil)
    // A visibility recheck already queued during SwiftUI layout must not restart a dismantled view.
    reader.updateSampling()
    #expect(!reader.isSampling)
    window.contentView = nil
}

@MainActor
private final class VisibleTestWindow: NSWindow {
    override var isVisible: Bool { true }
    override var occlusionState: NSWindow.OcclusionState { .visible }
}
