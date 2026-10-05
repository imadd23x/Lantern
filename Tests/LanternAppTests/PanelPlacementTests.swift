import AppKit
import Testing
@testable import LanternApp

@Test func cardChangesSizeAroundTheSameTopAnchor() {
    let bounds = CGRect(x: 0, y: 0, width: 1440, height: 900)
    let anchor = CGPoint(x: 720, y: 880)
    let compact = PanelPlacement.frame(size: PanelPlacement.compact, anchor: anchor, bounds: bounds)
    let expanded = PanelPlacement.frame(size: PanelPlacement.expanded, anchor: anchor, bounds: bounds)
    #expect(compact.midX == expanded.midX)
    #expect(compact.maxY == expanded.maxY)
    #expect(compact.size == PanelPlacement.compact)
    #expect(expanded.size == PanelPlacement.expanded)
}

@Test func rememberedCardStaysReachableAfterDisplayRemovalOrResize() {
    let bounds = CGRect(x: -1280, y: -200, width: 1280, height: 800)
    for anchor in [CGPoint(x: 4000, y: 4000), CGPoint(x: -4000, y: -4000)] {
        for size in [PanelPlacement.compact, PanelPlacement.expanded] {
            let frame = PanelPlacement.frame(size: size, anchor: anchor, bounds: bounds)
            #expect(bounds.insetBy(dx: 8, dy: 8).contains(frame))
        }
    }
}

@Test func invalidRememberedCoordinatesFallBackToVisibleTopCenter() {
    let bounds = CGRect(x: 0, y: 0, width: 1024, height: 768)
    let frame = PanelPlacement.frame(size: PanelPlacement.compact,
                                     anchor: CGPoint(x: CGFloat.nan, y: CGFloat.infinity), bounds: bounds)
    #expect(frame.midX == bounds.midX)
    #expect(frame.maxY == bounds.maxY - 8)
}
