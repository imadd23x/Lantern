import Foundation
import Darwin

public enum TransportError: Error, LocalizedError {
    case occupied, invalidPath, unsafeDirectory, disconnected, oversized, system(Int32)
    public var errorDescription: String? {
        switch self {
        case .occupied: "The Lantern socket already exists. Quit the other instance, or remove its stale socket after confirming it has stopped."
        case .invalidPath: "The local socket path is too long. Choose a shorter runtime directory."
        case .unsafeDirectory: "The runtime directory must be owned by you and cannot be a symbolic link."
        case .disconnected: "The companion disconnected. Answer in the original agent."
        case .oversized: "The hook message exceeds the local size limit."
        case .system(let code): "Local connection failed: \(String(cString: strerror(code)))"
        }
    }
}

enum SocketIO {
    static let maxFrame = 256_000
    static func address(_ path: String) throws -> sockaddr_un {
        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let bytes = Array(path.utf8CString)
        guard bytes.count <= MemoryLayout.size(ofValue: addr.sun_path) else { throw TransportError.invalidPath }
        withUnsafeMutableBytes(of: &addr.sun_path) { raw in
            for (i, byte) in bytes.enumerated() { raw[i] = UInt8(bitPattern: byte) }
        }
        return addr
    }

    static func configure(_ fd: Int32, timeout: TimeInterval) {
        var noSignal: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &noSignal, socklen_t(MemoryLayout.size(ofValue: noSignal)))
        var time = timeval(tv_sec: Int(timeout), tv_usec: Int32((timeout - floor(timeout)) * 1_000_000))
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &time, socklen_t(MemoryLayout.size(ofValue: time)))
        setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &time, socklen_t(MemoryLayout.size(ofValue: time)))
    }

    static func connectClient(_ fd: Int32, path: String, deadline: TimeInterval,
                              cancelled: (() -> Bool)?) throws {
        let original = fcntl(fd, F_GETFL)
        guard original >= 0, fcntl(fd, F_SETFL, original | O_NONBLOCK) == 0 else { throw TransportError.system(errno) }
        defer { _ = fcntl(fd, F_SETFL, original) }
        if cancelled?() == true { throw TransportError.disconnected }
        var address = try address(path)
        let result = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.connect(fd, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        if result != 0 {
            guard errno == EINPROGRESS else { throw TransportError.system(errno) }
            while true {
                if cancelled?() == true { throw TransportError.disconnected }
                let remaining = deadline - ProcessInfo.processInfo.systemUptime
                guard remaining > 0 else { throw TransportError.disconnected }
                var descriptor = pollfd(fd: fd, events: Int16(POLLOUT), revents: 0)
                let ready = poll(&descriptor, 1, Int32(ceil(min(0.1, remaining) * 1000)))
                if ready < 0, errno == EINTR { continue }
                guard ready >= 0 else { throw TransportError.system(errno) }
                if ready == 0 { continue }
                var failure: Int32 = 0
                var size = socklen_t(MemoryLayout<Int32>.size)
                guard getsockopt(fd, SOL_SOCKET, SO_ERROR, &failure, &size) == 0 else { throw TransportError.system(errno) }
                guard failure == 0, descriptor.revents & Int16(POLLOUT) != 0 else { throw TransportError.disconnected }
                break
            }
        }
        if cancelled?() == true || ProcessInfo.processInfo.systemUptime >= deadline { throw TransportError.disconnected }
    }

    static func readLine(_ fd: Int32, timeout: TimeInterval, cancelled: (() -> Bool)? = nil) throws -> Data {
        let deadline = ProcessInfo.processInfo.systemUptime + timeout
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while ProcessInfo.processInfo.systemUptime < deadline {
            if cancelled?() == true { throw TransportError.disconnected }
            let remaining = deadline - ProcessInfo.processInfo.systemUptime
            configure(fd, timeout: max(0.001, cancelled == nil ? remaining : min(remaining, 0.1)))
            let count = recv(fd, &buffer, buffer.count, 0)
            if count < 0, errno == EINTR { continue }
            if count < 0, errno == EAGAIN || errno == EWOULDBLOCK { continue }
            guard count > 0 else { throw TransportError.disconnected }
            let chunk = buffer.prefix(count)
            if let newline = chunk.firstIndex(of: 10) {
                guard result.count + newline <= maxFrame else { throw TransportError.oversized }
                result.append(contentsOf: chunk.prefix(newline))
                if cancelled?() == true { throw TransportError.disconnected }
                return result
            }
            guard result.count + count <= maxFrame else { throw TransportError.oversized }
            result.append(contentsOf: chunk)
        }
        throw TransportError.disconnected
    }

    static func writeLine(_ data: Data, fd: Int32, deadline: TimeInterval? = nil,
                          cancelled: (() -> Bool)? = nil) throws {
        guard data.count <= maxFrame else { throw TransportError.oversized }
        let bytes = data + Data([10])
        try bytes.withUnsafeBytes { pointer in
            var written = 0
            while written < bytes.count {
                if cancelled?() == true { throw TransportError.disconnected }
                if let deadline {
                    let remaining = deadline - ProcessInfo.processInfo.systemUptime
                    guard remaining > 0 else { throw TransportError.disconnected }
                    configure(fd, timeout: max(0.001, cancelled == nil ? remaining : min(0.1, remaining)))
                }
                let count = send(fd, pointer.baseAddress!.advanced(by: written), bytes.count - written, 0)
                if count < 0, errno == EINTR { continue }
                if count < 0, deadline != nil, errno == EAGAIN || errno == EWOULDBLOCK { continue }
                guard count > 0 else { throw TransportError.disconnected }
                written += count
            }
        }
    }
}
