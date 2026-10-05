import AppKit
import SwiftUI

/// Cache the supplied artwork once; packaged apps never fall back to an absolute build-cache path.
@MainActor
enum CompanionArtwork {
    static let portrait: NSImage? = {
        let resources: Bundle
        if Bundle.main.bundleURL.pathExtension == "app" {
            guard let url = Bundle.main.url(forResource: "Lantern_LanternApp", withExtension: "bundle"),
                  let bundle = Bundle(url: url) else { return nil }
            resources = bundle
        } else {
            resources = Bundle.module
        }
        guard let url = resources.url(forResource: "CompanionPortrait", withExtension: "webp") else { return nil }
        return NSImage(contentsOf: url)
    }()
}

struct LanternAvatar: View {
    let busy: Bool
    let attention: Bool
    @LanternReducedMotion private var reducedMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24, paused: reducedMotion || !busy)) { timeline in
            let time = reducedMotion || !busy ? 0 : timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geometry in
                let side = min(geometry.size.width, geometry.size.height)
                let shape = RoundedRectangle(cornerRadius: side * 0.20, style: .continuous)
                ZStack {
                    if let portrait = CompanionArtwork.portrait {
                        Image(nsImage: portrait).resizable().interpolation(.high).scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        Image(systemName: "person.crop.square").resizable().scaledToFit()
                            .foregroundStyle(Palette.subtle).padding(4)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipShape(shape)
                .overlay(shape.stroke(Palette.amber.opacity(attention ? 0.75 : 0.15), lineWidth: attention ? 1.5 : 1))
                .shadow(color: attention ? Palette.amber.opacity(0.25) : .clear, radius: 8)
                .offset(y: busy && !reducedMotion ? CGFloat(sin(time * 2.6)) * side * 0.02 : 0)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(attention ? "Lantern needs your attention" : busy ? "Lantern is watching active agents" : "Lantern is ready")
    }
}
