import Combine
import Foundation
import Testing
import LanternTransport
@testable import LanternApp

@MainActor
@Suite(.serialized)
struct ConnectionStatusTests {
    @Test func listenerPublishesConnectingThenReadyAndDisconnectsOnStop() throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-status-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = AppModel(directory: directory)
        defer { model.stop() }
        var statuses: [ConnectionStatus] = []
        let subscription = model.$connectionStatus.sink { statuses.append($0) }
        defer { subscription.cancel() }

        model.start()
        #expect(statuses == [.disconnected, .connecting, .connected])
        #expect(model.isListening && model.connectionStatus == .connected)
        #expect(FileManager.default.fileExists(atPath: model.socketPath))
        model.start() // Showing/reopening an already connected app cannot mark it failed.
        #expect(model.connectionStatus == .connected && model.errorMessage == nil)
        model.stop()
        #expect(model.connectionStatus == .disconnected && !model.isListening)
        #expect(!FileManager.default.fileExists(atPath: model.socketPath))
    }

    @Test func occupiedEndpointFailsWithoutRemovingOwnerAndCanRecover() throws {
        let directory = URL(fileURLWithPath: "/private/tmp/lantern-status-" + UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let owner = HookServer(directory: directory)
        try owner.start(onEvent: { _, _ in }, onDisconnect: { _ in })
        defer { owner.stop() }
        let model = AppModel(directory: directory)
        defer { model.stop() }

        model.start()
        #expect(model.connectionStatus == .failed && !model.isListening)
        #expect(model.errorMessage != nil)
        #expect(FileManager.default.fileExists(atPath: owner.socketPath))
        owner.stop()
        model.start()
        #expect(model.connectionStatus == .connected && model.isListening)
        #expect(model.errorMessage == nil)
    }
}
