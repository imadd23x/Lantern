import Foundation
import Darwin
import LanternCore
import LanternTransport

// Hook failure is a no-decision result. Only an explicit PermissionRequest response prints allow/deny.
@main
struct LanternHookApplication {
    static func main() {
        let parent = getppid() // Capture before consuming input, never a later reparented PID.
        do {
            let args = CommandLine.arguments
            guard let index = args.firstIndex(of: "--provider"), args.indices.contains(index + 1),
                  let provider = AgentProvider(rawValue: args[index + 1]) else { exit(0) }
            var data = Data()
            while let chunk = try FileHandle.standardInput.read(upToCount: min(8192, 200_001 - data.count)), !chunk.isEmpty {
                data.append(chunk)
                if data.count > 200_000 { exit(0) }
            }
            guard data.count <= 200_000, let event = try HookNormalizer.normalize(data, provider: provider) else { exit(0) }
            let cancelled: (() -> Bool)? = provider == .claude && event.kind == .approval
                ? { parent <= 1 || getppid() != parent } : nil
            let socketPath = RuntimeDirectory.current.appendingPathComponent("lantern.sock").path
            let decision = try HookClient.exchange(event, socketPath: socketPath, cancelled: cancelled)
            if event.kind == .approval, let output = decision.output, cancelled?() != true { print(output) }
        } catch {
            // Do not leak hook input, file contents, credentials, or technical errors into the agent.
            exit(0)
        }
    }
}
