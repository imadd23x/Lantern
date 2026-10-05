import AppKit
import SwiftUI

/// Packaging renders the same bundled portrait used in the panel, so artwork has one source.
@MainActor
enum IconRenderer {
    static func writeIconset(to directory: URL) throws {
        guard CompanionArtwork.portrait != nil else {
            throw CocoaError(.fileReadCorruptFile,
                userInfo: [NSLocalizedDescriptionKey: "The bundled companion portrait is missing or unreadable."])
        }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let artwork = LanternAvatar(busy: false, attention: false)
            .frame(width: 80, height: 80).frame(width: 100, height: 100)
            .background(Palette.background).clipShape(RoundedRectangle(cornerRadius: 23))
        for size in [16, 32, 128, 256, 512] {
            for scale in [1, 2] {
                let renderer = ImageRenderer(content: artwork)
                renderer.scale = CGFloat(size * scale) / 100
                guard let image = renderer.cgImage,
                      let bytes = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
                    throw CocoaError(.fileWriteUnknown)
                }
                let name = "icon_\(size)x\(size)\(scale == 2 ? "@2x" : "").png"
                try bytes.write(to: directory.appendingPathComponent(name))
            }
        }
    }
}
