import Foundation
import Testing
@testable import LanternApp

struct PanelLayoutTests {
    @Test func twoRowsShrinkAndAdditionalRowsGrowUntilTheyScroll() {
        let two = PanelLayout.size(sessionCount: 2, approval: false, notice: false)
        #expect(two.height < 350)
        #expect(two.height < PanelLayout.size(sessionCount: 3, approval: false, notice: false).height)
        #expect(PanelLayout.size(sessionCount: 20, approval: false, notice: false).height == PanelLayout.maximumHeight)
        #expect(two.width == PanelPlacement.expanded.width)
    }

    @Test func approvalReservesReadableProposalAndDecisionSpaceWithoutUnboundedGrowth() {
        let normal = PanelLayout.size(sessionCount: 2, approval: false, notice: false)
        let request = PanelLayout.size(sessionCount: 2, approval: true, notice: false)
        #expect(request.height > normal.height + 200)
        #expect(request.height <= PanelLayout.maximumHeight)
        #expect(PanelLayout.size(sessionCount: 20, approval: true, notice: true).height <= PanelLayout.maximumHeight)
        #expect(PanelLayout.size(sessionCount: 0, approval: false, notice: false).height < 460)
    }

    @Test func expandedDragAcceptsTheHeaderAndRejectsSessionAndApprovalContent() {
        #expect(PanelLayout.canDrag(expanded: true, pointFromTop: 35))
        #expect(!PanelLayout.canDrag(expanded: true, pointFromTop: 73))
        #expect(PanelLayout.canDrag(expanded: false, pointFromTop: 40))
        #expect(!PanelLayout.canDrag(expanded: false, pointFromTop: 47))
    }
}
