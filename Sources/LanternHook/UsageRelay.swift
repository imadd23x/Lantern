import Foundation
import Darwin
import LanternCore
import LanternTransport

enum UsageRelay {
    static func run(_ arguments: [String]) -> Int32 {
        guard let index = arguments.firstIndex(of: "--previous-status-line"), arguments.indices.contains(index + 1) else { return 0 }
        let previous: String?
        do { previous = try StatusLineConfiguration.previousCommand(snapshot: arguments[index + 1]) }
        catch { return 0 }

        var child: Process?
        var writer: FileHandle?
        if let previous {
            let process = Process()
            let pipe = Pipe()
            process.executableURL = URL(fileURLWithPath: "/bin/sh")
            process.arguments = ["-c", previous]
            process.standardInput = pipe
            process.standardOutput = FileHandle.standardOutput
            process.standardError = FileHandle.standardError
            do {
                try process.run()
                // Close our read endpoint so a child exiting without reading produces EPIPE.
                try pipe.fileHandleForReading.close()
                child = process; writer = pipe.fileHandleForWriting
            } catch { return 127 }
            // Install after spawning: the previous command retains its original signal dispositions.
            signal(SIGPIPE, SIG_IGN)
        }

        var data = Data()
        var oversized = false
        do {
            while let chunk = try FileHandle.standardInput.read(upToCount: 8192), !chunk.isEmpty {
                if !oversized {
                    if data.count + chunk.count <= 200_000 { data.append(chunk) }
                    else { oversized = true; data.removeAll() }
                }
                if let output = writer {
                    do { try output.write(contentsOf: chunk) }
                    catch { try? output.close(); writer = nil }
                }
            }
        } catch { oversized = true }
        try? writer?.close()
        if !oversized, let snapshot = try? ClaudeUsageSnapshot.statusLine(data) {
            let path = RuntimeDirectory.current.appendingPathComponent("lantern.sock").path
            _ = try? HookClient.exchange(ClaudeUsageEnvelope(snapshot: snapshot), socketPath: path)
        }
        if let child {
            child.waitUntilExit()
            return child.terminationReason == .uncaughtSignal ? 128 + child.terminationStatus : child.terminationStatus
        }
        return 0
    }
}
