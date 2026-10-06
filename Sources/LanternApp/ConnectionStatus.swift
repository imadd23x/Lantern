enum ConnectionStatus {
    case disconnected, connecting, connected, failed

    var title: String {
        switch self {
        case .disconnected: "Not connected"
        case .connecting: "Connecting"
        case .connected: "Connected"
        case .failed: "Connection failed"
        }
    }
}
