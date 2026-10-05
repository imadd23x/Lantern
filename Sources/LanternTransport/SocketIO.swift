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

    static func readLine(_ fd: Int32, timeout: TimeInterval) throws -> Data {
        let deadline = Date().timeIntervalSince1970 + timeout
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while Date().timeIntervalSince1970 < deadline {
            configure(fd, timeout: max(0.001, deadline - Date().timeIntervalSince1970))
            let count = recv(fd, &buffer, buffer.count, 0)
            if count < 0, errno == EINTR { continue }
            guard count > 0 else { throw TransportError.disconnected }
            let chunk = buffer.prefix(count)
            if let newline = chunk.firstIndex(of: 10) {
                guard result.count + newline <= maxFrame else { throw TransportError.oversized }
                result.append(contentsOf: chunk.prefix(newline))
                return result
            }
            guard result.count + count <= maxFrame else { throw TransportError.oversized }
            result.append(contentsOf: chunk)
        }
        throw TransportError.disconnected
    }

    static func writeLine(_ data: Data, fd: Int32) throws {
        guard data.count <= maxFrame else { throw TransportError.oversized }
        let bytes = data + Data([10])
        try bytes.withUnsafeBytes { pointer in
            var written = 0
            while written < bytes.count {
                let count = send(fd, pointer.baseAddress!.advanced(by: written), bytes.count - written, 0)
                if count < 0, errno == EINTR { continue }
                guard count > 0 else { throw TransportError.disconnected }
                written += count
            }
        }
    }
}
