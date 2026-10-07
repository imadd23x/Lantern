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

@Test func detailsRevealReadinessSurvivesRelayoutAndRapidReversal() {
    var readiness = PanelRevealReadiness()
    readiness.update(expanded: true, reduced: false, now: 100)
    readiness.update(expanded: true, reduced: false, now: 100.1) // Observer relayout during opening.
    #expect(readiness.remaining(at: 100.1) > 0.29)
    readiness.update(expanded: false, reduced: false, now: 100.2)
    readiness.update(expanded: true, reduced: false, now: 100.2)
    #expect(readiness.remaining(at: 100.3) > 0.29)
    readiness.update(expanded: false, reduced: true, now: 100.3)
    readiness.update(expanded: true, reduced: true, now: 100.3)
    #expect(readiness.remaining(at: 100.3) == 0)
}
