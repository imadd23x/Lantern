import Foundation
import LanternCore
import LanternTransport

/// Blocking socket reads must not occupy Swift's cooperative workers while awaiting actor callbacks.
/// Tests retain their real transport, deadlines and independently selectable in-flight requests.
public func startHookExchange(_ event: AgentEvent, socketPath: String,
                              timeout: TimeInterval? = nil) -> Task<HookDecision, Error> {
    Task {
        try await withCheckedThrowingContinuation { continuation in
            Thread.detachNewThread {
                continuation.resume(with: Result {
                    try HookClient.exchange(event, socketPath: socketPath, timeout: timeout)
                })
            }
        }
    }
}
